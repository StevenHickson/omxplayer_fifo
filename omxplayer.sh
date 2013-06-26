#!/bin/bash
#
# OMXPlayer wrapper script. Fixes some common issues.
#
# Author: Sergio Conde <skgsergio@gmail.com>
# License: GPLv2
#

if [ -e /usr/bin/omxplayer.bin ]; then
  OMXPLAYER="/usr/bin/omxplayer.bin"
else
  OMXPLAYER="./omxplayer.bin"
fi

if [ -e /usr/share/fonts/truetype/freefont/FreeSans.ttf ]; then
  FONT="/usr/share/fonts/truetype/freefont/FreeSans.ttf"
else
  FONT="fonts/FreeSans.ttf"
fi

if [ -e /usr/lib/omxplayer ]; then
  export LD_LIBRARY_PATH=/opt/vc/lib:/usr/lib/omxplayer:$LD_LIBRARY_PATH
else
  export LD_LIBRARY_PATH=$PWD/ffmpeg_compiled/usr/local/lib:/opt/vc/lib:$LD_LIBRARY_PATH
fi

$OMXPLAYER --font $FONT "$@"

if [ ! -z $NOREFRESH ] && [ "$NOREFRESH" == "1" ]; then
    exit 0
fi

GREP=`which grep`
if [ ! -z $GREP ]; then
    echo "$@" | $GREP -E "\.(mp3|wav|wma|cda|ogg|ogm|aac|ac3|flac)( |$)" > /dev/null 2>&1
    if [ "$?" == "0" ]; then
        exit 0
    fi
fi

FBSET=`which fbset`
if [ ! -z $FBSET ]; then
    DEPTH2=`$FBSET | head -3 | tail -1 | cut -d " " -f 10`

    if [ "$DEPTH2" == "8" ]; then
        DEPTH1=16
    elif [ "$DEPTH2" == "16" ] || [ "$DEPTH2" == "32" ]; then
        DEPTH1=8
    else
        DEPTH1=8
        DEPTH2=16
    fi

    $FBSET -depth $DEPTH1 > /dev/null 2>&1
    $FBSET -depth $DEPTH2 > /dev/null 2>&1
fi

XSET=`which xset`
XREFRESH=`which xrefresh`
if [ ! -z $XSET ] && [ ! -z $XREFRESH ]; then
    if [ -z $DISPLAY ]; then
        DISPLAY=":0"
    fi

    $XSET -display $DISPLAY -q > /dev/null 2>&1
    if [ "$?" == "0" ]; then
        $XREFRESH -display $DISPLAY > /dev/null 2>&1
    fi
fi
