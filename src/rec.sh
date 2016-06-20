#!/bin/bash

if [ $# -lt 1 ]; then
  echo "usage: $0 length-to-record[min] [title]"
  exit 1
fi
length=$(($1 * 60))
title=`date "+%Y%m%d"`-${2-agqr}

/usr/local/bin/rtmpdump -r rtmp://fms-base1.mitene.ad.jp/agqr/aandg22 --live -B $length -o /opt/agqr/$title.flv
