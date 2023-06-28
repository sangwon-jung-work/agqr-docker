#!/bin/sh
# agqr new recording shell(with while loop)
# 2022.03.04 first create
# 2022.04.02 change while condition le to lt
# 2023.06.28 change buffer time 35 to 30 seconds, change break count 15 to 10
# 2023.06.29 add sleep interval before fail retry
#
# ./rec_agqr_failover.sh 30 "AGQR_REC"
#

# param count
if [ $# -lt 1 ]; then
  echo "usage: $0 length-to-record[min] [title]"
  exit 1
fi

# Recording Info from params
REC_MIN=$1
PREFIX=$2

# change for each Env
REC_HOME=/workspace
DOCKER_HOME=/usr/bin/docker
SLEEP_HOME=/usr/bin/sleep
IMAGE_NAME="(image_name):(image_version)"

# for failover
TOTAL_SECONDS=$(($REC_MIN * 60))
BUFF_SECONDS=$(($TOTAL_SECONDS - 30))
RETRY_INTERVAL_SECONDS=15
FAIL_COUNT=

echo "${PREFIX} agqr recoder will running ${TOTAL_SECONDS} sec"

$DOCKER_HOME run --rm -v $REC_HOME:/var/agqr $IMAGE_NAME $REC_MIN $PREFIX .

# Rework if finished 30 seconds earlier than the original work time
while [ "$SECONDS" -lt "$BUFF_SECONDS" ]
do
  echo "${PREFIX} agqr recoder finished less than ${BUFF_SECONDS} sec."
  
  FAIL_COUNT=$[ $FAIL_COUNT +1]
  
  # if FAIL_COUNT is grater than 10, break while
  if [ "$FAIL_COUNT" -gt 10 ];
  then
    echo "FAIL_COUNT ${FAIL_COUNT} is grater than 10. stop recording"
    break
  fi
  
  secs=$SECONDS
  hrs=$(( secs/3600 ))
  mins=$(( (secs-hrs*3600)/60 ))
  secs=$(( secs-hrs*3600-mins*60 ))
  
  printf 'Time spent: %02d:%02d:%02d\n' $hrs $mins $secs
  
  # recal REC_MIN
  REC_MIN_RECAL=$(($REC_MIN - ((hrs*60) + $mins)))
  TOTAL_SECONDS=$(($REC_MIN_RECAL * 60))
  
  echo "${PREFIX} agqr recoder will running ${TOTAL_SECONDS} sec after ${RETRY_INTERVAL_SECONDS} later"
  
  # if REC_MIN_RECAL is negative number, break while
  if [ "$REC_MIN_RECAL" -lt 0 ];
  then
    echo "REC_MIN_RECAL ${REC_MIN_RECAL} is cannot negative value. stop recording"
    break
  fi
  
  $SLEEP_HOME $RETRY_INTERVAL_SECONDS
  
  $DOCKER_HOME run --rm -v $REC_HOME:/var/agqr $IMAGE_NAME $REC_MIN_RECAL $PREFIX$FAIL_COUNT .
  
  if [ $? != 0 ];
  then
    echo "exit on recording error from rec_agqr_failover"
    break
  fi
  
done
