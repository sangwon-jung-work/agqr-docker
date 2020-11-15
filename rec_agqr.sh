#!/bin/bash
#
# 2020.03.22 URL aandg1b -> aandg1

if [ $# -lt 1 ]; then
  echo "usage: $0 length-to-record[min] [title] [outpath]"
  exit 1
fi

if [ $# -lt 2 ]; then
  echo "usage: $0 length-to-record[min] [title] [outpath]"
  exit 1
fi

length=$(($1 * 60))
DATES=`date '+%Y%m%d'`
title=${2-agqr}_$DATES
outdir="."

if [ $# -ge 3 ]; then
  outdir=$3
fi


/usr/bin/rtmpdump -r rtmp://fms-base1.mitene.ad.jp/agqr/aandg1 --live -B $length -o /tmp/$title.flv


# convert mp4 video
ffmpeg -loglevel quiet -y -i "/tmp/${title}.flv" -vcodec copy -acodec copy "${outdir}/${title}.mp4"


if [ $? = 0 ]; then
    rm -f "/tmp/${title}.flv"
    # mv /tmp/$title.flv $outdir 
fi
