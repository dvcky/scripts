#!/bin/sh
if [[ $# -eq 1 ]]; then
    echo "--------"
    echo "FILE: $1"
    echo "--------"

    echo "(1/3) Fetching metadata from file..."

    INEXT="${1##*.}"

    INFOLDER="${1%/*}"

    # variables with potentially non-filesafe values that are used for naming files (thus, requiring a "filesafe" format)
    TITLE="$(exiftool -b -Title "$1" | sed 's/^[ \t]*//')"
    TITLE_FILESAFE="$(echo $TITLE | sed -e 's/[<>:"/\|?*\t]//g')"
    ARTIST="$(exiftool -b -Artist "$1" | sed 's/^[ \t]*//')"
    ARTIST_FILESAFE="$(echo $ARTIST | sed -e 's/[<>:"/\|?*\t]//g')"
    ALBUMARTIST="$(exiftool -b -AlbumArtist "$1" | sed 's/^[ \t]*//')"
    ALBUMARTIST_FILESAFE="$(echo $ALBUMARTIST | sed -e 's/[<>:"/\|?*\t]//g')"
    ALBUM="$(exiftool -b -Album "$1" | sed 's/^[ \t]*//')"
    ALBUM_FILESAFE="$(echo $ALBUM | sed -e 's/[<>:"/\|?*\t]//g')"

    # should not have a non-filesafe value or where filesafe value is not needed
    GENRE=$(exiftool -b -Genre "$1" | sed 's/^[ \t]*//')
    YEAR=$(exiftool -b -Year "$1" | sed 's/^[ \t]*//')
    TRACKNUMBER="$(exiftool -b -TrackNumber "$1" | cut -d'/' -f-1 | cut -d' ' -f-1 | sed 's/^[ \t]*//')"
    if [[ -z $TRACKNUMBER ]]; then
        TRACKNUMBER="$(exiftool -b -Track "$1" | cut -d'/' -f-1 | cut -d' ' -f-1 | sed 's/^[ \t]*//')"
    fi
    DISCNUMBER="$(exiftool -b -DiscNumber "$1" | cut -d'/' -f-1 | cut -d' ' -f-1 | sed 's/^[ \t]*//')"
    if [[ -z $DISCNUMBER ]]; then
        DISCNUMBER="$(exiftool -b -DiskNumber "$1" | cut -d'/' -f-1 | cut -d' ' -f-1 | sed 's/^[ \t]*//')"
        if [[ -z $DISCNUMBER ]]; then
            DISCNUMBER="1"
        fi
    fi
    if [[ ! -z $TRACKNUMBER ]]; then
        NUMTRACKS="$(find "$INFOLDER" -maxdepth 1 -iname "*.$INEXT" | wc -l)"
        NUMDIGITS="${#NUMTRACKS}"
        FLOATINGTRACKNUM="$(printf "%0"$NUMDIGITS"d" "$((10#$TRACKNUMBER))")"
    fi

    COVERFILE="cover.jpg"

    if [[ $(find "$INFOLDER" -maxdepth 1 -iname "*.$INEXT" | wc -l) == 1 && ($DISCNUMBER -eq 1 || -z "$DISCNUMBER") ]]
    # if there is only 1 file of that extention in the directory with a disc number value of 1 or nothing...
    then
        ALBUM=""
        ALBUM_FILESAFE=""
        TRACKNUMBER=""
        COVERFILE=$ARTIST_FILESAFE" - "$TITLE_FILESAFE".jpg"
    fi

    # set values for those that are missing and need to exist
    if [[ -z "$ALBUMARTIST_FILESAFE" ]]; then
        if [[ ! -z "$ARTIST_FILESAFE" ]]
        then
            ALBUMARTIST_FILESAFE="$ARTIST_FILESAFE"
        else
            ALBUMARTIST_FILESAFE="Unknown"
        fi
    fi
    if [[ -z "$ALBUM_FILESAFE" ]]; then
        ALBUM_FILESAFE="Unknown"
    fi
    if [[ -z "$ARTIST_FILESAFE" ]]; then
        ARTIST_FILESAFE="Unknown"
    fi
    if [[ -z "$TITLE_FILESAFE" ]]; then
        TITLE_FILESAFE="Unknown"
    fi

    # finally, the aac file naming scheme
    OUTFILE=$FLOATINGTRACKNUM". "$ARTIST_FILESAFE" - "$TITLE_FILESAFE".m4a"
    if [[ -z $TRACKNUMBER ]]; then
        OUTFILE=$ARTIST_FILESAFE" - "$TITLE_FILESAFE".m4a"
    fi

    OUTFOLDER="encode/$ALBUMARTIST_FILESAFE - $ALBUM_FILESAFE CD$(printf "%02d" "$((10#$DISCNUMBER))")"
    if [[ "$ALBUM_FILESAFE" == "Unknown" ]]; then
        OUTFOLDER="encode/$ALBUMARTIST_FILESAFE - Singles"
        if [[ "$ARTIST_FILESAFE" == "Unknown" ]]; then
            OUTFOLDER="encode/!!! UNKNOWN"
        fi
    fi

    OUTFILE_PATH=$OUTFOLDER"/"$OUTFILE



    if [[ ! -f "$OUTFILE_PATH" ]]
    # if transcoded file does not exist already...
    then
        mkdir -p "$OUTFOLDER"
        INCOVER=$(find "$INFOLDER" -maxdepth 1 -iname "cover.jpg" -o -iname "cover.png" -o -iname "folder.jpg" -o -iname "folder.png" -o -iname "front.jpg" -o -iname "front.png")
        OUTCOVER=$(find "$OUTFOLDER" -maxdepth 1 -iname "cover.jpg" -o -iname "cover.png" -o -iname "folder.jpg" -o -iname "folder.png" -o -iname "front.jpg" -o -iname "front.png")

        # for multi-disc albums
        if [[ ! -n "$INCOVER" && ${INFOLDER##*/} == Disc* ]]
        # if we don't find an INCOVER and the folder is a Disc folder, check the folder above it instead
        then
            INCOVER=$(find "${INFOLDER%/*}" -maxdepth 1 -iname "cover.jpg" -o -iname "cover.png" -o -iname "folder.jpg" -o -iname "folder.png" -o -iname "front.jpg" -o -iname "front.png")
        fi

        if [[ ! -n "$OUTCOVER" ]]
        # if we don't find an OUTCOVER
        then
            if [[ -n "$INCOVER" ]]
            # if we do find an INCOVER, convert it and copy to the OUTFOLDER
            then
                convert "$INCOVER" -resize '600x600>' "$OUTFOLDER/$COVERFILE"
            else
            # otherwise, try ripping the cover from the files metadata
                exiftool -b -Picture "$1" > "$OUTFOLDER/$COVERFILE"
                if [[ ! -s "$OUTFOLDER/$COVERFILE" ]]; then
                    exiftool -b -CoverArt "$1" > "$OUTFOLDER/$COVERFILE"
                fi
                if [[ ! -s "$OUTFOLDER/$COVERFILE" ]]
                # if we get nothing from that, give up
                then
                    echo "NO ALBUM ART FOUND!"
                    rm "$OUTFOLDER/$COVERFILE"
                else
                # otherwise, convert this and move it to OUTFOLDER
                    convert "$OUTFOLDER/$COVERFILE" -resize '600x600>' "$OUTFOLDER/$COVERFILE"
                fi

            fi
        fi

        OUTFILE_WAV=$FLOATINGTRACKNUM". "$ARTIST_FILESAFE" - "$TITLE_FILESAFE".wav"
        if [[ -z $TRACKNUMBER ]]; then
            OUTFILE_WAV=$ARTIST_FILESAFE" - "$TITLE_FILESAFE".wav"
        fi
        echo "(2/3) Creating temporary Waveform..."
        ffmpeg -nostdin -hide_banner -loglevel error -i "$1" -f wav -ar 44100 "$OUTFILE_WAV" -y

        echo "(3/3) Encoding temporary file with qaac..."
        WINEDEBUG=-all wine qaac64.exe --tvbr 109 --quality 2 --title "$TITLE" --artist "$ARTIST" --band "$ALBUMARTIST" --album "$ALBUM" --genre "$GENRE" --date "$YEAR" --track "$TRACKNUMBER" --disk "$DISCNUMBER" "$OUTFILE_WAV"
        mv "$OUTFILE" "$OUTFILE_PATH"
        rm "$OUTFILE_WAV"

        echo
    else
    # otherwise, skip
        echo "(!/3) File already exists, skipping..."
        echo
    fi
fi
