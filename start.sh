#!/bin/bash

# Nginx SSL代理容器 - 快速启动脚本
set -e  # 遇到错误时退出

echo "=== Nginx SSL代理容器快速启动 ==="
echo

# 检查是否存在.env文件
if [ ! -f ".env" ]; then
    echo "未找到.env文件，正在创建模板..."
    cp .env.example .env
    echo "请编辑 .env 文件配置您的域名和邮箱"
    echo "完成后重新运行此脚本"
    exit 1
fi

# 读取配置
echo "当前配置："
echo "容器名称: $(grep CONTAINER_NAME .env | cut -d'=' -f2)"
echo "域名: $(grep DOMAINS .env | cut -d'=' -f2)"
echo "邮箱: $(grep EMAIL .env | cut -d'=' -f2)"
echo "代理主机: $(grep PROXY_HOST .env | cut -d'=' -f2):$(grep PROXY_PORT .env | cut -d'=' -f2)"
echo

# 询问用户是否继续
read -p "是否继续启动？(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消启动"
    exit 1
fi

# 创建必要的目录
echo "创建必要的目录..."
mkdir -p logs
mkdir -p conf/conf.d

# 检查Docker和Docker Compose是否可用
if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装或未在PATH中"
    echo ""
    echo "请确保已安装Docker Desktop for Windows:"
    echo "1. 访问 https://www.docker.com/products/docker-desktop/"
    echo "2. 下载并安装Docker Desktop"
    echo "3. 启动Docker Desktop并等待其完全启动"
    echo "4. 重新运行此脚本"
    exit 1
fi

# 检查Docker Compose（支持新旧语法）
if ! docker compose version &> /dev/null; then
    echo "错误: Docker Compose未安装或未在PATH中"
    echo ""
    echo "Docker Compose应该包含在Docker Desktop中，请确保："
    echo "1. Docker Desktop已完全启动（状态栏图标显示为运行中）"
    echo "2. 重新打开终端或命令行窗口"
    echo "3. 重新运行此脚本"
    exit 1
fi

# 构建和启动
echo "构建Docker镜像..."
docker compose build
if [ $? -ne 0 ]; then
    echo "错误: Docker镜像构建失败"
    exit 1
fi
echo "启动服务..."
docker compose up -d
if [ $? -ne 0 ]; then
    echo "错误: 服务启动失败"
    echo "查看错误日志: docker compose logs"
    exit 1
fi

echo "服务已启动！"
echo
echo "=== 状态检查 ==="
docker compose ps

echo
echo "=== 使用说明 ==="
echo "查看日志: docker compose logs -f"
echo "停止服务: docker compose down"
echo "重启服务: docker compose restart"
echo "进入容器: docker compose exec nginx bash"
echo "检查配置: docker compose exec nginx nginx -t"