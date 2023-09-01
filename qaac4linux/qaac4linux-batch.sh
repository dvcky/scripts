#!/bin/sh

FIND_FILTER=""

# USER CUSTOMIZED OPTIONS
# SUPPORTED_FILES - file extensions you want this program to look for
# PROCESSES - number of transcode processes that can run simultaniously (I recommend 75-80% of your cores as a good starting point for high-load without constantly pinning your CPU to 100%)
SUPPORTED_FILES="flac m4a mp3"
PROCESSES=12

for FILETYPE in $SUPPORTED_FILES; do
    if [[ ! -z "$FIND_FILTER" ]]
    then
        FIND_FILTER=$FIND_FILTER" -o -iname *."$FILETYPE""
    else
        FIND_FILTER="-iname *."$FILETYPE""
    fi
done

find "$1" -type f $FIND_FILTER | while read FILE
do
    ((i=i%PROCESSES)); ((i++==0)) && wait
    ./qaac4linux-convert.sh "$FILE" &
done
