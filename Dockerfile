#syntax=docker/dockerfile:1
FROM nginx:1.21.6
RUN rm -Rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y cron certbot python3-certbot-nginx gettext-base && \
    apt-get clean && rm -rf /var/cache/apt/*

COPY ./conf/crontab/crontab /etc/cron.d/crontab
COPY ./conf/autocert/run.sh /etc/autocert/run.sh
RUN chmod 0644 /etc/cron.d/certbot
RUN chmod 0655 /etc/autocert/run.sh
RUN /usr/bin/crontab /etc/cron.d/crontab

CMD /etc/autocert/run.sh "$DOMAINS" "$EMAIL" "$COUNTRY" "$PROXY_HOST" "$PROXY_PORT" && tail -f /dev/null