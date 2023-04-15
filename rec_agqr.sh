#!/bin/bash
#
# 2020.11.13 copy rec_agqr.sh
# 2021.01.02 add FFREPORT (output log information variable)
# 2021.08.08 add reconnect_on_network_error option for Connection timed out
# 2022.01.09 add referer header
# 2022.02.19 add exit 1 code on not success exit
# 2023.03.09 add extract stream_url by condition, file output log, modify temp file name
# 2023.04.03 modify new url pattern after maintanance
# 2023.04.15 add ffmpeg discardcorrupt flag
#

if [ $# -lt 2 ]; then
  echo "usage: $0 length-to-record[min] [title] [outpath]"
  exit 1
fi


LENGTH=$(($1 * 60))
TODAY=`date '+%Y%m%d'`
PREFIX=${2-AGQR}
TITLE=${PREFIX}_${TODAY}
OUTDIR="."

DOMAIN=https://www.uniqueradio.jp
BASE_URL="${DOMAIN}/agplayer5"

AGQR_TEMP1="${OUTDIR}/${TITLE}_1player"
AGQR_TEMP2="${OUTDIR}/${TITLE}_2iframe"
AGQR_TEMP3="${OUTDIR}/${TITLE}_3stream"
AGQR_TEMP4="${OUTDIR}/${TITLE}.mp4"

LOG_FILE="${OUTDIR}/log/agqr_shell_${PREFIX}.log.$TODAY"


#
# write a log in file
#
writelog() {
  \echo `\date +"%Y-%m-%d %T"` "$1" >> $LOG_FILE
}



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
  OUTDIR=$3
fi

# check exist log folder
if [ ! -d $OUTDIR/log ];
then
  mkdir $OUTDIR/log
fi


# get player php url in main page's html
curl --insecure "${BASE_URL}/player.php" -X GET | grep php > "${AGQR_TEMP1}"

if [ $? != 0 ]; then
  #echo "error player.php" > "${AGQR_TEMP1}_error"
  #echo "AGQR_TEMP1 error"
  writelog "AGQR_TEMP1 error"
fi

#echo "player"
#echo "AGQR_TEMP1 $(cat ${AGQR_TEMP1})"
writelog "AGQR_TEMP1 $(cat ${AGQR_TEMP1})"


playerurl=$( xmllint --html --xpath //iframe/@src "${AGQR_TEMP1}" | sed 's/ src="\([^"]*\)"/\1/g' )

#echo "playerurl"
#echo $playerurl



# get m3u8 line in player php page's html
curl --insecure "${BASE_URL}/${playerurl}" -X GET | grep m3u8 > "${AGQR_TEMP2}"

if [ $? != 0 ]; then
  #echo "error iframe.php" > "${AGQR_TEMP2}_error"
  #echo "AGQR_TEMP2 error"
  writelog "AGQR_TEMP2 error"
fi

#echo "source"
#echo "AGQR_TEMP2 $(cat ${AGQR_TEMP2})"
writelog "AGQR_TEMP2 $(cat ${AGQR_TEMP2})"

# parse src string
SOURCE_URL=$( xmllint --html --xpath //source/@src "${AGQR_TEMP2}" | sed 's/ src="\([^"]*\)"/\1/g' )

#echo "SOURCE_URL ${SOURCE_URL}"
writelog "SOURCE_URL ${SOURCE_URL}"

# for test
#SOURCE_URL="https://hls-base1.mitene.ad.jp/agqr1/iphone/3Gs.m3u8"

STREAM_URL=""

# Whether the URL starts absolute address in the source tag
if [[ $SOURCE_URL == http* ]];
then
  STREAM_URL="${SOURCE_URL}"
  
else
  
  curl -o $AGQR_TEMP3 $DOMAIN$SOURCE_URL
  
  if [ $? != 0 ];
  then
    # fail curl job
    #echo "error get m3u8 body job"
    writelog "error get m3u8 body job"
  
  else
    
    # AGQR_TEMP3 file null check
    if [ -s $AGQR_TEMP3 ];
    then
      #echo "AGQR_TEMP3 file NOT EMPTY"
      writelog "AGQR_TEMP3 file NOT EMPTY"
      
      # then file get 404 not found string
      if [ "$(grep -c "404 Not Found" "$AGQR_TEMP3")" -ge 1 ];
      then
        #echo "error get m3u8 body in script url"
        writelog "error get m3u8 body in script url"
      fi
      
    else
      
      # AGQR_TEMP3 file is empty
      #echo "get m3u8 body is null"
      writelog "get m3u8 body is null"
      
      # AGQR_TEMP3 file null check if end
    fi
    
    # curl job fail check if end
  fi
  
  STREAM_URL=$( grep -m 1 -Rh m3u8 "${AGQR_TEMP3}" )
  
  # SOURCE_URL string check end
fi

#echo "STREAM_URL ${STREAM_URL}"
writelog "STREAM_URL ${STREAM_URL}"


# set ffmpeg log variable(output file info, set log level debug
export FFREPORT=file=$OUTDIR/log/agqr_ffmpeg_$PREFIX.log.$TODAY:level=48

# start record 
ffmpeg -reconnect_on_network_error 1 -fflags discardcorrupt -headers "Referer: ${DOMAIN}/" -i "${STREAM_URL}" -vcodec copy -acodec copy -t $LENGTH "${AGQR_TEMP4}"

# remove temp files
if [ $? = 0 ]; then
  rm -f "${AGQR_TEMP1}" "${AGQR_TEMP2}" "${AGQR_TEMP3}"
else
  rm -f "${AGQR_TEMP1}" "${AGQR_TEMP2}" "${AGQR_TEMP3}"
  echo "exit on error"
  exit 1
fi

