#!/bin/sh

FIND_FILTER=""

# qaac4linux settings:
# ----

SUPPORTED_FILES="flac m4a mp3" # list of file types you want to be transcoded
PROCESSES=12 # number of transcoding processes to run asynchronously

# ----

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
