#!/bin/bash

# Set sane bash defaults
set -o errexit
set -o pipefail

OPTION="$1"
ACCESS_KEY=${ACCESS_KEY:?"ACCESS_KEY required"}
SECRET_KEY=${SECRET_KEY:?"SECRET_KEY required"}
S3PATH=${S3PATH:?"S3_PATH required"}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 * * * *}
S3CMDPARAMS=${S3CMDPARAMS}

LOCKFILE="/tmp/s3cmd.lock"
LOG="/var/log/cron.log"

echo "access_key=$ACCESS_KEY" >> /root/.s3cfg
echo "secret_key=$SECRET_KEY" >> /root/.s3cfg

if [ ! -e $LOG ]; then
  touch $LOG
fi

if [[ $OPTION = "start" ]]; then
  CRONFILE="/etc/cron.d/s3backup"
  CRONENV=""

  echo "Found the following files and directores mounted under /data:"
  echo
  ls -F /data
  echo

  echo "Adding CRON schedule: $CRON_SCHEDULE"
  CRONENV="$CRONENV ACCESS_KEY=$ACCESS_KEY"
  CRONENV="$CRONENV SECRET_KEY=$SECRET_KEY"
  CRONENV="$CRONENV S3PATH=$S3PATH"
  CRONENV="$CRONENV S3CMDPARAMS=$S3CMDPARAMS"
  echo "$CRON_SCHEDULE root $CRONENV bash /run.sh backup" >> $CRONFILE

  echo "Starting CRON scheduler: $(date)"
  cron
  exec tail -f $LOG 2> /dev/null

elif [[ $OPTION = "backup" ]]; then
  echo "Starting sync: $(date)" | tee $LOG

  if [ -f $LOCKFILE ]; then
    echo "$LOCKFILE detected, exiting! Already running?" | tee -a $LOG
    exit 1
  else
    touch $LOCKFILE
  fi

  echo "Executing s3cmd sync $S3CMDPARAMS /data/ $S3PATH..." | tee -a $LOG
  /usr/local/bin/s3cmd sync $S3CMDPARAMS /data/ $S3PATH 2>&1 | tee -a $LOG
  rm -f $LOCKFILE
  echo "Finished sync: $(date)" | tee -a $LOG

else
  echo "Unsupported option: $OPTION" | tee -a $LOG
  exit 1
fi
