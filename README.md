# Docker s3backup

TODO: Write better readme. :)

You need to set the following env variables:

- ACCESS_KEY
- SECRET_KEY
- S3PATH

Mount your desired folders under /data, and they will be backed up every hour.
Use the `CRON_SCHEDULE` env to set a custom schedule in the `* * * * *` standard
CRON format.
