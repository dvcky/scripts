#!/bin/sh

check_and_copy_cover() {
    # the below checks are because people dont use consistent cover file name standards
    FINDCASE_FILE=$(find "$1" -iname "$2") # check current folder
    FINDCASE_FILE_UP_ONE=$(find "${1%/*}" -iname "$2") # check parent folder (common for multi-disk)
    FINDCASE_ANY_IMAGE=$(find "$1" -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" | head -1) # worst case just check for an image, any image - then take the first one
    if [[ -n "$FINDCASE_FILE" ]]; then
        magick "$FINDCASE_FILE" -strip -resize "x300>" "$3/cover.jpg"
        return 0
    elif [[ -n "$FINDCASE_FILE_UP_ONE" ]]; then
        magick "$FINDCASE_FILE_UP_ONE" -strip -resize "x300>" "$3/cover.jpg"
        return 0
    elif [[ -n "$FINDCASE_ANY_IMAGE" ]]; then
        magick "$FINDCASE_ANY_IMAGE" -strip -resize "x300>" "$3/cover.jpg"
        return 0
    fi
    return 1
}

if [[ -n $1 ]] && [[ -n $2 ]]; then
    find "$1" -type f -iname "*.flac" | while read FILE
    do
        OLDFOLDER="${FILE%/*}"
        TEMP="${FILE#$1}"
        NEWFILE="$2/${FILE#$1}"
        NEWFOLDER="${NEWFILE%/*}"

        if [[ ! -f "$NEWFILE" ]]; then
            #echo "Copying $FILE..."
            mkdir -p "$NEWFOLDER"
            cp "$FILE" "$NEWFILE"
            metaflac --remove --block-type=PICTURE,PADDING "$NEWFILE"

            ALBUMARTIST=$(metaflac --show-tag=ALBUMARTIST "$FILE")
            ALBUMARTIST=${ALBUMARTIST#*ALBUMARTIST=}
            ALBUM=$(metaflac --show-tag=ALBUM "$FILE")
            ALBUM=${ALBUM#*ALBUM=}

            if [[ ! -f "$NEWFOLDER/cover.jpg" ]]; then

                cover_types=("cover.jpg" "cover.png" "cover.jpeg" "$ALBUMARTIST - $ALBUM.jpg" "$ALBUMARTIST - $ALBUM.png" "$ALBUM.jpg" "$ALBUM.png" "folder.jpg" "folder.png" "front.jpg" "front.png")
                for cover_type in "${cover_types[@]}"; do
                    if check_and_copy_cover "$OLDFOLDER" "$cover_type" "$NEWFOLDER"; then
                        break
                    fi
                done
            fi

            if [[ ! -f "$NEWFOLDER/cover.jpg" ]]; then
                metaflac --export-picture-to="$OLDFOLDER/cover.jpg" "$FILE" > /dev/null 2>&1
                if [[ $? -eq 0 ]]; then
                    if check_and_copy_cover "$OLDFOLDER" "cover.jpg" "$NEWFOLDER"; then
                        rm "$OLDFOLDER/cover.jpg"
                    fi
                else
                    echo "NO COVER FOUND! -> $TEMP"
                fi
            fi
        fi
    done
    cd "$2"
    sync
fi
