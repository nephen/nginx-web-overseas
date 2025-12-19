# Nginx SSL 代理容器

这是一个通用的Nginx SSL代理容器，支持自动SSL证书申请和反向代理功能。

## 特性

- 🔒 自动SSL证书申请（Let's Encrypt）
- 🔄 自动证书续期
- 🚀 反向代理支持
- 📋 通用配置模板
- 🐳 Docker容器化部署

## 前置要求

### Windows系统
- **Docker Desktop for Windows** - 请访问 [Docker官网](https://www.docker.com/products/docker-desktop/) 下载并安装
- **Git Bash** 或其他终端工具

### 安装步骤
1. 下载并安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. 启动Docker Desktop并等待其完全启动（状态栏图标显示为运行中）
3. 重新打开终端或命令行窗口
4. 验证安装：`docker --version` 和 `docker compose version`

## 部署方式

### 方式一：使用Docker Hub镜像（推荐）

适用于大多数用户，无需本地构建，直接部署：

```bash
# 1. 创建项目目录
mkdir nginx-proxy && cd nginx-proxy

# 2. 下载部署文件
wget https://raw.githubusercontent.com/your-repo/main/docker-compose.hub.yml -O docker-compose.yml
# 或者手动创建 docker-compose.yml 文件，使用 docker-compose.hub.yml 的内容

# 3. 创建并编辑 .env 文件
cp .env.example .env
# 编辑 .env 文件，设置你的域名和邮箱

# 4. 启动服务
docker compose up -d
```

### 方式二：本地构建（开发者）

适用于需要修改源码或自定义构建的情况：

#### 1. 配置环境变量

⚠️ **重要提示**：`.env` 文件包含敏感配置信息，**不要**提交到版本控制！

复制 `.env.example` 为 `.env` 并修改配置：

```sh
cp .env.example .env
```

编辑 `.env` 文件，设置你的域名和邮箱：

```env
# 容器配置
CONTAINER_NAME=nginx-cert

# 域名配置（多个域名用逗号分隔）
DOMAINS=yourdomain.com,www.yourdomain.com

# 邮箱配置（用于SSL证书申请）
EMAIL=your-email@example.com

# 代理配置
PROXY_HOST=127.0.0.1
PROXY_PORT=8080

# 国家代码（用于SSL证书）
COUNTRY=US

# Nginx端口
NGINX_PORT=80
```

### 2. 启动服务

#### 本地构建方法1：使用快速启动脚本（推荐）

```sh
# 给脚本执行权限
chmod +x start.sh

# 运行启动脚本
./start.sh
```

#### 本地构建方法2：手动启动

```sh
# 构建镜像
docker compose build

# 启动服务
docker compose up -d

# 查看日志
docker compose logs -f

# 停止服务
docker compose down
```

## 项目结构

```
├── conf/
│   ├── autocert/          # 自动证书申请脚本
│   ├── crontab/           # 定时任务配置
│   └── templates/         # Nginx配置模板
├── logs/                  # Nginx日志目录
├── docker compose.yml     # Docker Compose配置
├── Dockerfile            # Docker镜像构建文件
├── start.sh              # 快速启动脚本
├── .env.example          # 环境变量配置示例
├── .gitignore            # Git忽略文件配置
└── README.md             # 项目文档
```

## 高级配置

### 自定义Nginx配置

如果需要自定义Nginx配置，可以：

1. 修改 `conf/templates/default.conf.template` 文件
2. 在 `conf/conf.d/` 目录下添加额外的配置文件

### 多域名配置

支持配置多个域名，用逗号分隔：

```env
DOMAINS=example.com,www.example.com,api.example.com
```

### 代理配置

可以配置反向代理的目标地址：

```env
PROXY_HOST=127.0.0.1
PROXY_PORT=3000
```

### 环境变量说明

| 变量名 | 必填 | 默认值 | 说明 |
|--------|------|--------|------|
| CONTAINER_NAME | 否 | nginx-cert | 容器名称 |
| DOMAINS | 是 | - | 域名列表，逗号分隔 |
| EMAIL | 是 | - | SSL证书申请邮箱 |
| PROXY_HOST | 否 | 127.0.0.1 | 反向代理目标主机 |
| PROXY_PORT | 否 | 8080 | 反向代理目标端口 |
| COUNTRY | 否 | US | SSL证书国家代码 |
| NGINX_PORT | 否 | 80 | Nginx监听端口 |

## 常用命令

### 快速启动脚本命令
```sh
# 给脚本执行权限
chmod +x start.sh

# 运行启动脚本
./start.sh
```

### Docker Compose命令

```sh
# 构建镜像
docker compose build

# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 查看日志
docker compose logs -f

# 进入容器
docker compose exec nginx bash

# 重启服务
docker compose restart

# 查看服务状态
docker compose ps

# 检查Nginx配置
docker compose exec nginx nginx -t
```

## 注意事项

### 安全提示
- **`.env` 文件包含敏感信息，务必添加到 `.gitignore` 中，不要提交到版本控制**
- 首次运行时会自动申请SSL证书，可能需要几分钟时间
- 确保80端口未被占用
- 域名需要正确解析到服务器IP
- 建议配置防火墙规则，只允许80和443端口

### 故障排查
- 检查容器状态：`docker compose ps`
- 查看服务日志：`docker compose logs -f`
- 验证Nginx配置：`docker compose exec nginx nginx -t`
- 检查证书状态：`docker compose exec nginx certbot certificates`

### 调试
查看日志，进入容器查看网络。
```sh
cd logs
tail -f error.log
docker compose exec nginx bash
apt-get install net-tools
netstat -antp
tcp6       0      0 :::8080                 :::*                    LISTEN      43/nginx: master pr 
tcp6       0      0 :::80                   :::*                    LISTEN      43/nginx: master pr
tcp6       0      0 :::443                  :::*                    LISTEN      43/nginx: master pr
```

## 常见问题

### SSL证书申请失败
- **DNS解析问题**：确保域名已正确解析到服务器IP
- **防火墙问题**：检查80端口是否开放
- **速率限制**：Let's Encrypt有申请频率限制，失败后等待一段时间再试

### 常见错误及解决方案

**错误：`open() "/etc/letsencrypt/options-ssl-nginx.conf" failed`**
- 解决方案：停止服务，清空数据目录，重新启动

**错误：`client with the currently selected authenticator does not support any combination of challenges that will satisfy the CA. You may need to use an authenticator plugin that can do challenges over DNS.`**
- 解决方案：检查域名解析配置，确保使用HTTP-01挑战方式

**错误：`There were too many requests of a given type :: Error creating new order :: too many failed authorizations recently: see https://letsencrypt.org/docs/failed-validation-limit/`**
- 解决方案：等待1小时后再尝试，或更换域名

## 开发者指南

### 构建和推送Docker镜像

#### 自动构建（GitHub Actions）

1. 在GitHub仓库中设置Secrets：
   - `DOCKERHUB_USERNAME`: 你的Docker Hub用户名
   - `DOCKERHUB_TOKEN`: 你的Docker Hub访问令牌

2. 推送代码到main分支或创建标签，GitHub Actions会自动构建并推送镜像

3. 手动触发构建：
   - 进入GitHub仓库的Actions页面
   - 选择"Build and Push Docker Image"工作流
   - 点击"Run workflow"，输入标签名

#### 手动构建和推送

使用提供的构建脚本：

```bash
# 给脚本执行权限
chmod +x build-and-push.sh

# 构建并推送latest标签
./build-and-push.sh nephen2023

# 构建并推送指定标签
./build-and-push.sh nephen2023 v1.0.0
```

或者直接使用Docker命令：

```bash
# 登录Docker Hub
docker login

# 构建镜像
docker build -t nephen2023/nginx-web-overseas:latest .

# 推送镜像
docker push nephen2023/nginx-web-overseas:latest
```

### 项目文件说明

- `docker-compose.yml`: 本地构建版本（原有功能保持不变）
- `docker-compose.hub.yml`: Docker Hub镜像部署版本
- `build-and-push.sh`: 手动构建和推送脚本
- `.github/workflows/docker-build.yml`: GitHub Actions自动构建配置

### 添加新域名
要添加新域名而不影响现有域名：
```sh
# 进入容器
docker compose exec nginx bash

# 手动申请新域名证书
certbot --nginx --non-interactive --agree-tos -m your-email@example.com --domains new-domain.com

# 重启Nginx
nginx -s reload
```