#!/bin/bash

if [ $# -lt 1 ]; then
  echo "usage: ./$% length-to-record[sec] [title]"
  exit 1
fi
length=$1
title=${2-agqr}

/usr/local/bin/rtmpdump -r rtmp://fms-base1.mitene.ad.jp/agqr/aandg22 --live -B $length -o /tmp/$title.flv
