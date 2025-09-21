#!/bin/sh

# Since reaper doesn't include a desktop file, here's a manually created one:

reaper_desktop_file() {
    echo "[Desktop Entry]"
    echo "Encoding=UTF-8"
    echo "Type=Application"
    echo "Name=REAPER"
    echo "Comment=REAPER"
    echo "Categories=Audio;Video;AudioVideo;AudioVideoEditing;Recorder;"
    echo "Exec=\"$HOME/REAPER/reaper\" %F"
    echo "Icon=$HOME/REAPER/Resources/main.png"
    echo "MimeType=application/x-reaper-project;application/x-reaper-project-backup;application/x-reaper-theme"
    echo "StartupWMClass=REAPER"
}


# Get OS information

OS_DISTRIBUTION=$(grep -Po '^ID=["]?\K[^"]+' /etc/os-release)
OS_DIST_VERSION=$(grep -Po '^VERSION_ID=["]?\K[^"]+' /etc/os-release)

# Exit script if OS is not Fedora 41 running in a Distrobox container

if [[ "$OS_DISTRIBUTION $OS_DIST_VERSION" != "fedora 41"* ]] && [[ -z "$CONTAINER_ID" ]]; then
    echo "Error! This script only supports Fedora 41 running in Distrobox!"
    exit 1
fi

echo "----------------"
echo "UPDATING SYSTEM"
echo "----------------"

sudo dnf upgrade -y

echo "----------------"
echo "INSTALLING DAVINCI RESOLVE"
echo "----------------"

# Fixes directory permissions error during installation
sudo mkdir -p /var/BlackmagicDesign
sudo chown $USER /var/BlackmagicDesign

# Install ROCm repository
AMDGPU_INSTALL_URL="https://repo.radeon.com/amdgpu-install/latest/rhel/9.6/$(curl https://repo.radeon.com/amdgpu-install/latest/rhel/9.6/ | grep -oP '<a href=".+?">\K[^../].+?(?=<)')"
sudo dnf install -y $AMDGPU_INSTALL_URL

# Each line of package install represents the following below (in order):
# 1. Initial DaVinci Resolve check prerequisites
# 2. DaVinci Resolve's listed prerequisites (post-fuse install)
# 3. Fixes error with creating shortcuts during installation
# 4. Fixes libcrypt.so.1 missing error
# 5. Fixes missing audio issues in distrobox environment (gtk3 requires pipewire-alsa), and fixes issue with REAPER later
# 6. ROCm for hardware accelerated computing on AMD GPUs
# 7. Required for yabridge (adds support for Windows DAW plugins in Linux)

sudo dnf install -y \
fuse fuse-libs \
alsa-lib apr apr-util fontconfig freetype libglvnd libglvnd-egl libglvnd-glx libglvnd-opengl librsvg2 libXcursor libXfixes libXi libXinerama libxkbcommon-x11 libXrandr libXrender libXtst libXxf86vm mesa-libGLU mtdev pulseaudio-libs xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm zlib \
gtk-update-icon-cache xdg-utils \
libxcrypt-compat \
gtk3 \
rocm \
wine

# Execute DaVinci Resolve installer, completely in terminal and with no prompt to confirm (we just want this to be fast)

read -p "Drag DaVinci Resolve '.run' file here, then press enter: " RESOLVE_INSTALLER
chmod +x "$RESOLVE_INSTALLER"
SKIP_PACKAGE_CHECK=1 "${RESOLVE_INSTALLER% }" -iynC "$HOME/resolve" # SKIP_PACKAGE_CHECK=1 is needed on Fedora 41, otherwise installer will not start (it says we are missing zlib, when in reality we have it installed already)

# Make DaVinci Resolve's included libraries inaccessible to the program - that way we don't run into issues with version mismatch and linking

mkdir -p "$HOME/resolve/libs/disabled"
mv "$HOME/resolve/libs/libglib"* "$HOME/resolve/libs/disabled"
mv "$HOME/resolve/libs/libgio"* "$HOME/resolve/libs/disabled"
mv "$HOME/resolve/libs/libgmodule"* "$HOME/resolve/libs/disabled"

# Now that it is properly installed, link application to host system

distrobox-export --app "$HOME/.local/share/applications/com.blackmagicdesign.resolve.desktop"

echo "----------------"
echo "INSTALL REAPER"
echo "----------------"

read -p "Drag your copy of 'reaper725_linux_x86_64.tar.xz' here, then press enter: " REAPER_ARCHIVE
tar -xf "${REAPER_ARCHIVE% }" -C "$HOME" --strip-components=2

# Manual installation of reaper does not include the .desktop file and icon - adding below for a proper experience

xdg-icon-resource install --size 256 "$HOME/REAPER/Resources/main.png" cockos-reaper
reaper_desktop_file > "$HOME/.local/share/applications/fm.reaper.desktop"

# Now that it is properly installed, link application to host system

distrobox-export --app "$HOME/.local/share/applications/fm.reaper.desktop"

echo "----------------"
echo "INSTALL YABRIDGE"
echo "----------------"
echo
mkdir -p "$HOME/.local/share"
read -p "Drag your copy of 'yabridge-X.X.X.tar.gz' here, then press enter: " YABRIDGE_ARCHIVE
tar -xf "$YABRIDGE_ARCHIVE" -C "$HOME/.local/share"

# Then add yabridgectl binary to local user path so that it is easily accessible

chmod +x "$HOME/.local/share/yabridge/yabridgectl"
mkdir -p "$HOME/.local/bin"
ln -sf "$HOME/.local/share/yabridge/yabridgectl" "$HOME/.local/bin"

# Now that everything is done, say something nice to the user :)

echo
echo "COMPLETED! Thanks for using Ducky's avbox script! :)"
