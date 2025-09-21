# avbox
A script that creates an audio (REAPER) and video (DaVinci Resolve) production environment on any Linux desktop system with an AMD GPU that supports Distrobox with ease!

### Why?
_"With tools like davincibox already existing, why is this needed?"_

While DaVinci Resolve does have plenty of tools out there that streamline the installation in various environments, I have yet to find one that does the same with REAPER - much less bundles the two together! Closed-source applications on Linux can be quite picky about their dependencies, and as such it only made sense to add REAPER to the script as well.

_"REAPER works well on Linux - you shouldn't need a special environment for it!"_

Credit where credit is due, REAPER's native experience is _really_ good - however, once you add yabridge into the mix (which adds support for Windows DAW plugins - still a must for many creators) it can start to get a little messy.

_Why not just use a tool like davincibox, and then install REAPER afterwards?_

I like switching environments a lot, and having a script that automates this process saves me a lot of time setting things up in the long run.

### Installation
1. Right click [this link](https://github.com/dvcky/scripts/raw/main/avbox/avbox.sh), then save it to a file _(You can call it whatever you want, but for reference to this guide we will be calling it `avbox.sh`)_
2. Install [BoxBuddy](https://github.com/Dvlv/BoxBuddyRS) using your preferred method.
3. Create a new Distrobox

![](https://raw.githubusercontent.com/dvcky/scripts/refs/heads/main/avbox/step1.png)

4. Fill in the settings to something similar to below (the name of the system and the home folder does not have to be avbox, it can be anything - I would just recommend that you use a seperate home folder from your host system to keep things more organized)

![](https://raw.githubusercontent.com/dvcky/scripts/refs/heads/main/avbox/step2.png)

3. Run `chmod +x ./avbox.sh && ./avbox.sh`
4. Grab a cup of coffee, watch as text scrolls, and follow the prompts as necessary. You can grab the files the script will ask for ahead of time in [Files Required](#files-required) if you would like, and that will save you some of time as well.
5. Success! The applications should be available from your host system's application list, and anything that needs configuring can be done from the container's home folder since all of the applications are installed there.

### Files Required

* **DaVinci Resolve installer:** [https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion](https://www.blackmagicdesign.com/support/family/davinci-resolve-and-fusion) - the ".run" file that the script asks you for is located inside of the zip file.
* **REAPER v7.25 "portable":** `Cockos.REAPER.v7.25.Linux.x64-BTCR.rar` - I should preface this by saying that REAPER is an excellent piece of software, and you should purchase it before doing this. That being said, having a portable, preregistered copy ready-to-go has been a lot more convenient for me, so avbox uses this version of REAPER for the installation. I will not be providing a link to this file for legal reasons, but if you download it and dig through the archive you should find a file labeled `reaper725_linux_x86_64.tar.xz` - this is what you need for the script.
* **yabridge:** [https://github.com/robbert-vdh/yabridge/releases/latest](https://github.com/robbert-vdh/yabridge/releases/latest) - the ".tar.gz" file should be all you need.
