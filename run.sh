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

LOG="/var/log/cron.log"
if [ ! -e $LOG ]; then
  mkfifo $LOG
fi

echo "access_key=$ACCESS_KEY" >> /root/.s3cfg
echo "secret_key=$SECRET_KEY" >> /root/.s3cfg

if [[ $OPTION = "start" ]]; then
  CRONFILE="/etc/cron.d/s3backup"
  CRONENV=""
  echo "Adding CRON schedule: $CRON_SCHEDULE"
  CRONENV="$CRONENV ACCESS_KEY=$ACCESS_KEY"
  CRONENV="$CRONENV SECRET_KEY=$SECRET_KEY"
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
