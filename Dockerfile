#syntax=docker/dockerfile:1
FROM nginx:1.21.6
RUN rm -Rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y cron certbot python3-certbot-nginx gettext-base dos2unix && \
    apt-get clean && rm -rf /var/cache/apt/*

COPY ./conf/crontab/crontab /etc/cron.d/certbot
COPY ./conf/autocert/run.sh /etc/autocert/run.sh

# 转换换行符并设置权限
RUN dos2unix /etc/cron.d/certbot && chmod 0644 /etc/cron.d/certbot
RUN dos2unix /etc/autocert/run.sh && chmod 0755 /etc/autocert/run.sh

CMD /etc/autocert/run.sh "$DOMAINS" "$EMAIL" "$COUNTRY" "$PROXY_HOST" "$PROXY_PORT" && tail -f /dev/null