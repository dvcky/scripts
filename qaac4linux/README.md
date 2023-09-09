# qaac4linux
QAAC for linux, all bundled in a convenient little package!

### Why?
QAAC (or QuickTime AAC) is a proprietary codec made by Apple. With all the amazing codecs out there, why go out of your way to get this one working?
1. **It's the best older lossy codec that is widely supported.** For context, I have an old iPod 5.5g I am storing lots of my music on. The stock iPod OS only supports AAC, MP3, ALAC, WAV, and AIFF. Of these, only AAC & MP3 are lossy, and MP3 is the worse of the two.
2. **It's lossy, so it saves space!** Going back to the iPod, I do not have much space, but I do have quite a large library! (~15k songs so far!) Because of this, lossless music is not a realistic expectation.
3. **It's fast.** Again with the iPod, slower processor means worse performance and higher battery usage. I can absolutely install RockBox and get OPUS support, which is an arguably much better lossy codec, but it makes the whole thing chug to a hault. Hopefully in the future OPUS decoding on RockBox gets better, but until then, this is the next best option.
4. **It's high quality.** Like I mentioned previously, MP3 is worse than AAC. AAC can produce approximately the same quality at about 80% of the filesize, which is great!

Ultimately, this was made because I got an old iPod and wanted to have a good experience with it. But at the very least, it was a great learning experience!

### Installation
1. Right click [this link](https://github.com/dvcky/scripts/raw/main/qaac4linux/qaac4linux-installer.sh), then save it to a file _(You can call it whatever you want, but for reference to this guide we will be calling it `qaac4linux-installer.sh`)_
2. Navigate to the folder of the file and open a terminal emulator of your choice
3. Run `chmod +x ./qaac4linux-installer.sh && ./qaac4linux-installer.sh`
4. Done! qaac4linux should now be installed in a folder called `qaac_(QAAC VERSION)`

### Directory Structure

First, lets talk about the files we just acquired:

Navigate into the `qaac_(QAAC VERSION)` folder, and you will find a couple of things:
- **QTfiles64:** this is a folder that contains files from Apple that enable QuickTime encoding through QAAC
- **tmp_downloads:** this is where the files that were downloaded during the installation are placed after everything has been extracted. if you would like, you may delete this folder
- **libsoxconvolver64.dll, libsoxr64.dll, qaac64.exe, & refalac64.exe:** the QAAC tool itself and its necessary files for utilizing QTfiles
- **qaac4linux-batch.sh & qaac4linux-convert.sh:** these are my custom scripts for convenient conversion. once again, if you would like you may delete these files, but I highly recommend keeping them! _(follow our [Usage](#usage) guide for more details!)_

### Usage

_

##### qaac4linux-convert.sh
This script is for converting a single audio file. Given the file has metadata, it will try to read it using `exiftool`, and then organize files given that information. If the information is not available or my script cannot read it, it will label it as "Unknown". All files will be stored in a directory next to the script called "encode".

Lastly, at the top of the file there are two settings that can be adjusted:
- `COVER_HEIGHT`: Defines the height of the cover art for the file you are converting in pixels. The cover width will be decided automatically based on the aspect ratio of the original image. Height will be ignored if larger than the original cover art height. _(examples: a 2000x1000 image will be converted to 600x300 given the value `300`, but a 200x250 image will just be copied over at the same resolution given the same value)_
- `QAAC_QUALITY`: I recommend you check out the _"TVBR bitrate mapping (AAC)"_ table on [this](https://wiki.hydrogenaud.io/index.php?title=Apple_AAC#Bitrate_modes) page for more information on this, but basically, this is Apple's weird equation for bitrate. By default I have it set to `109`, which should get you ~256kbps on average. _(this is about equivalent to 320kbps MP3)_

_Example command:_ `./qaac4linux-convert.sh "/path/to/file.flac"`

_

##### qaac4linux-batch.sh
This script is for batch converting folders of several audio files. It basically runs `qaac4linux-convert.sh` several times asyncronously and recursively over a folder you've given it and utilizes filters you provide with the settings below:
- `SUPPORTED_FILES`: Gives a list of file extensions for qaac4linux to look for. For example, given `flac mp3`, qaac4linux will look for and transcode all files ending in ".flac" and ".mp3"
- `PROCESSES`: The number of transcoding processes to run asynchronously. I recommend about 75% of your threads as a good number. For example, I have it set to `12` because my CPU has 16 threads.

_Example command:_ `./qaac4linux-batch.sh "/path/to/folder"`
