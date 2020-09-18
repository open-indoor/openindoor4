################ OSM GETTER #############
FROM debian:buster
RUN apt-get -y update \
    && apt-get -y install \
    cron \
    procps \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/bin
COPY ./getOsmFiles.sh ./getOsmFiles.sh
RUN chmod +x ./getOsmFiles.sh
RUN echo "* * * * * /usr/bin/flock -w 0 /var/tmp/getOsmFiles.lock /usr/bin/getOsmFiles.sh > /dev/stdout 2> /dev/stderr" > /etc/cron.d/getOsmFiles-cron
RUN crontab /etc/cron.d/getOsmFiles-cron
CMD bash -c 'echo "Start cron task" && crontab -l && /usr/sbin/cron -f -l 8'