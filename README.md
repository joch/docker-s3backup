# S3Backup

S3Backup is a Docker container which backs up one or more folders to S3 using
the s3cmd sync tool.

To tell s3backup what to back up, mount your desired volumes under the
`/data` directory.

s3backup is configured by setting the following environment variables during
the launch of the container.

- ACCESS_KEY - your AWS access key
- SECRET_KEY - your AWS secret key
- S3PATH - your S3 bucket and path
- S3CMDPARAMS - custom parameters to s3cmd

Files are by default backed up once every hour. You can customize this behavior
using an environment variable which uses the standard CRON notation.

- `CRON_SCHEDULE` - set to `0 * * * *` by default, which means every hour.

## Example invocation

To backup the `Documents` and the `Photos` directories in your home folder, and
running the backup at 03:00 every day, you could use something like this:

```
docker run -d -v /home/user/Documents:/data/documents:ro -v $/home/user/Photos:/data/photos -e "ACCESS_KEY=YOURACCESSKEY" -e "SECRET_KEY=YOURSECRET" -e "S3PATH=s3://yours3bucket/" -e "CRON_SCHEDULE=0 3 * * *" joch/s3backup
```
