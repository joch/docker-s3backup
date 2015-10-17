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
  mkfifo $LOG
fi

# Create lock to make sure only one copy is being executed
if [ -f $LOCKFILE ]; then
  echo "$LOCKFILE detected, exiting! Already running?" | tee $LOG
  exit 1
else
  touch $LOCKFILE
fi

if [[ $OPTION = "start" ]]; then
  CRONFILE="/etc/cron.d/s3backup"
  CRONENV=""
  echo "Adding CRON schedule: $CRON_SCHEDULE"
  CRONENV="$CRONENV S3PATH=$S3PATH"
  #CRONENV="$CRONENV S3CMDPARAMS=$S3CMDPARAMS"
  echo "$CRON_SCHEDULE root $CRONENV bash /run.sh backup" >> $CRONFILE
  echo "Starting CRON scheduler: $(date)"
  cron
  exec tail -f $LOG
elif [[ $OPTION = "backup" ]]; then
  # Do the synchronization
  echo "Starting sync: $(date)" > $LOG
  /usr/local/bin/s3cmd sync /data/ $S3PATH > $LOG 2>&1
  echo "Finished sync: $(date)" > $LOG
fi

rm -f $LOCKFILE
