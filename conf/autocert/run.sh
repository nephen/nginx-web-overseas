#!/bin/bash

# 获取参数
DOMAINS=$1
EMAIL=$2
COUNTRY=$3
PROXY_HOST=$4
PROXY_PORT=$5

# 参数验证
if [ -z "$DOMAINS" ] || [ -z "$EMAIL" ] || [ -z "$COUNTRY" ] || [ -z "$PROXY_HOST" ] || [ -z "$PROXY_PORT" ]; then
    echo "Error: Missing required parameters"
    echo "Usage: $0 <domains> <email> <country> <proxy_host> <proxy_port>"
    exit 1
fi

echo "Starting nginx-cert with configuration:"
echo "Domains: $DOMAINS"
echo "Email: $EMAIL"
echo "Country: $COUNTRY"
echo "Proxy Host: $PROXY_HOST"
echo "Proxy Port: $PROXY_PORT"

# 确保必要的目录存在
mkdir -p /etc/nginx/conf.d
mkdir -p /etc/nginx/templates
mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

# 启动cron服务
service cron start
if [ $? -ne 0 ]; then
    echo "Error: Failed to start cron service"
    exit 1
fi

# Create a self signed certificate, should the user need it
echo "Creating self-signed certificate..."
openssl req -subj "/C=$COUNTRY/" -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/default-server.key -out /etc/ssl/certs/default-server.crt
if [ $? -ne 0 ]; then
    echo "Error: Failed to create self-signed certificate"
    exit 1
fi

# Generate nginx configuration from template if it doesn't exist
if [ ! -f "/etc/nginx/conf.d/default.conf" ]; then
    echo "Generating nginx configuration..."
    
    # 设置环境变量供Nginx模板使用
    export DOMAINS=$(echo $DOMAINS | tr ',' ' ')
    export PROXY_HOST=$PROXY_HOST
    export PROXY_PORT=$PROXY_PORT
    
    # 使用envsubst替换模板中的变量
    if [ -f "/etc/nginx/templates/default.conf.template" ]; then
        envsubst '${DOMAINS} ${PROXY_HOST} ${PROXY_PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf
    else
        # 如果没有模板文件，直接生成配置
        cat > /etc/nginx/conf.d/default.conf << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name $(echo $DOMAINS | tr ',' ' ');

    location / {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Host \$http_host;
        proxy_pass http://$PROXY_HOST:$PROXY_PORT;

        proxy_set_header REMOTE_ADDR \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Referer \$http_referer;
        real_ip_recursive on;
    }
}
EOF
    fi
fi

# https://www.nginx.com/blog/using-free-ssltls-certificates-from-lets-encrypt-with-nginx/
if [ ! -z "$DOMAINS" ] && [ ! -z "$EMAIL" ]; then
    echo "Requesting SSL certificates..."
    certbot --nginx --non-interactive --agree-tos -m "$EMAIL" --domains "$DOMAINS"
    if [ $? -ne 0 ]; then
        echo "Warning: SSL certificate generation failed, using self-signed certificate"
    fi
else
    echo "Skipping SSL certificate generation - DOMAINS or EMAIL not provided"
fi

# Restart NGINX
echo "Restarting Nginx..."
/etc/init.d/nginx restart
if [ $? -ne 0 ]; then
    echo "Error: Failed to restart Nginx"
    exit 1
fi
echo "Nginx-cert setup completed successfully!"