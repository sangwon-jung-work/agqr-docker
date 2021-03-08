#!/bin/bash
#
# 2020.11.13 copy rec_agqr.sh
# 2021.01.02 add FFREPORT (output log information variable)
#

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
PREFIX=${2-agqr}
title=${PREFIX}_${DATES}
outdir="."

BASE_URL=https://www.uniqueradio.jp/agplayer5


# check essential tools
if ! curl --version &> /dev/null
then
    echo "curl could not be found"
    exit 1
fi

if ! xmllint --version &> /dev/null
then
    echo "xmllint could not be found"
    exit 1
fi

if ! ffmpeg -version &> /dev/null
then
    echo "ffmpeg could not be found"
    exit 1
fi



if [ $# -ge 3 ]; then
  outdir=$3
fi



# get player php url in main page's html
curl --insecure "${BASE_URL}/player.php" -X GET | grep php > "${outdir}/${title}_tempTag1"

if [ $? != 0 ]; then
  echo "error player.php" > "${outdir}/${title}_tempTag1Error"
fi

#echo "player"
#cat "${outdir}/${title}_tempTag2"

playerurl=$( xmllint --html --xpath //iframe/@src "${outdir}/${title}_tempTag1" | sed 's/ src="\([^"]*\)"/\1/g' )

#echo "playerurl"
#echo $playerurl



# get m3u8 line in player php page's html
curl --insecure "${BASE_URL}/${playerurl}" -X GET | grep m3u8 > "${outdir}/${title}_tempTag2"

if [ $? != 0 ]; then
  echo "error iframe.php" > "${outdir}/${title}_tempTag2Error"
fi

#echo "source"
#cat "${outdir}/${title}_tempTag2"

# parse src string
listurl=$( xmllint --html --xpath //source/@src "${outdir}/${title}_tempTag2" | sed 's/ src="\([^"]*\)"/\1/g' )

#echo "listurl"
#echo $listurl



# get recording streaming url
curl $BASE_URL/$listurl > "${outdir}/${title}_tempUrl"

if [ $? != 0 ]; then
  echo "error url" > "${outdir}/${title}_tempUrl_Error"
fi

streamurl=$( grep -m 1 -Rh m3u8 "${outdir}/${title}_tempUrl" )

#echo "streamurl"
#echo $streamurl


# check exist log folder
if [ ! -d $outdir/log ];
then
  mkdir $outdir/log
fi

# set ffmpeg log variable(output file info, set log level debug
export FFREPORT=file=$outdir/log/agqr_$PREFIX.log.$DATES:level=48


# start record
ffmpeg -i "${streamurl}" -vcodec copy -acodec copy -t $length "${outdir}/${title}.mp4"



# remove temp files
if [ $? = 0 ]; then
  rm -f "${outdir}/${title}_tempTag1" "${outdir}/${title}_tempTag2" "${outdir}/${title}_tempUrl"
else
  rm -f "${outdir}/${title}_tempTag1" "${outdir}/${title}_tempTag2" "${outdir}/${title}_tempUrl"
fi

