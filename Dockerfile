FROM debian:jessie
MAINTAINER Johnny Chadda <johnny@chadda.se>

ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cron python python-magic python-pip && \
    rm -rf /var/lib/apt/lists/*

RUN pip install s3cmd

ADD s3cmd.cfg /root/.s3cfg
ADD run.sh /

ENTRYPOINT ["/run.sh"]
CMD ["start"]
