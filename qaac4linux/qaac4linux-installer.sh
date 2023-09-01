#!/bin/sh
QAAC_VER="2.80"
QTFILES_VER="12.10.11"
PREREQ_MISSING=""

echo
echo
echo
echo "Welcome to Ducky's Quick QAAC Installer for Linux!"
echo

echo -n "Checking for prerequisites..."

if [[ ! -n $(whereis curl | cut -d':' -f2-) ]]; then
    PREREQ_MISSING=$PREREQ_MISSING" curl"
fi

if [[ ! -n $(whereis 7z | cut -d':' -f2-) ]]; then
    PREREQ_MISSING=$PREREQ_MISSING" 7z"
fi

if [[ ! -n $(whereis exiftool | cut -d':' -f2-) ]]; then
    PREREQ_MISSING=$PREREQ_MISSING" exiftool"
fi

if [[ ! -n $(whereis ffmpeg | cut -d':' -f2-) ]]; then
    PREREQ_MISSING=$PREREQ_MISSING" ffmpeg"
fi

if [[ ! -n $(whereis wine | cut -d':' -f2-) ]]; then
    PREREQ_MISSING=$PREREQ_MISSING" wine"
fi

if [[ -z "$PREREQ_MISSING" ]]
then
    echo "success!"

    echo "(1/6) Downloading the encoder..."
    curl -Lo qaac_$QAAC_VER.zip https://github.com/nu774/qaac/releases/download/v$QAAC_VER/qaac_$QAAC_VER.zip --progress-bar

    echo "(2/6) Extracting the encoder..."
    7z e qaac_$QAAC_VER.zip "qaac_$QAAC_VER/x64/*" -oqaac_$QAAC_VER -y > /dev/null

    echo "(3/6) Cleaning up files so far..."
    mkdir qaac_$QAAC_VER/tmp_downloads
    mv qaac_$QAAC_VER.zip qaac_$QAAC_VER/tmp_downloads/
    cd qaac_$QAAC_VER

    echo "(4/6) Downloading QuickTime files..."
    curl -Lo QTfiles64.7z https://github.com/AnimMouse/QTFiles/releases/download/v$QTFILES_VER/QTfiles64.7z --progress-bar

    echo "(5/6) Extracting QuickTime files..."
    7z x QTfiles64.7z -oQTfiles64 -y > /dev/null

    echo "(6/6) Cleaning up some more..."
    mv QTfiles64.7z tmp_downloads/

    echo "(7/7) Downloading custom scripts..."
    curl -Lo qaac4linux-convert.sh https://raw.githubusercontent.com/dvcky/scripts/main/qaac4linux/qaac4linux-convert.sh --progress-bar
    chmod +x qaac4linux-convert.sh
    curl -Lo qaac4linux-batch.sh https://raw.githubusercontent.com/dvcky/scripts/main/qaac4linux/qaac4linux-batch.sh --progress-bar
    chmod +x qaac4linux-batch.sh

    echo
    echo "Done! A folder called 'qaac_$QAAC_VER' has been created with all the files needed for the QAAC encoder!"
    echo
    echo "You can use './qaac4linux-convert.sh FILE' for single files, and './qaac4linux-batch.sh FOLDER' for folders."
    echo
    echo
    echo
else
    echo "ERROR!"
    echo
    echo "You are missing the following prerequisites:"
    echo " >"$PREREQ_MISSING
    echo "Please install the respective package for each of these executables on your operating system, then try again!"
    echo
    echo
    echo
fi
