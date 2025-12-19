#!/bin/bash

# Docker Hub构建和推送脚本
# 用于手动构建和推送镜像到Docker Hub

set -e

echo "=== Docker Hub镜像构建和推送工具 ==="
echo

# 检查参数
if [ $# -eq 0 ]; then
    echo "用法: $0 <docker-hub-用户名> [镜像标签]"
    echo "示例:"
    echo "  $0 myusername          # 推送 latest 标签"
    echo "  $0 myusername v1.0.0    # 推送 v1.0.0 标签"
    exit 1
fi

DOCKERHUB_USERNAME=$1
TAG=${2:-latest}
IMAGE_NAME="${DOCKERHUB_USERNAME}/nginx-web-overseas:${TAG}"

echo "配置信息:"
echo "Docker Hub用户名: ${DOCKERHUB_USERNAME}"
echo "镜像标签: ${TAG}"
echo "完整镜像名: ${IMAGE_NAME}"
echo

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker未安装"
    exit 1
fi

# 检查是否已登录Docker Hub
echo "检查Docker Hub登录状态..."
if ! docker info | grep -q "Username"; then
    echo "请先登录Docker Hub:"
    echo "docker login"
    exit 1
fi

# 显示当前登录用户
echo "当前Docker Hub用户: $(docker info | grep Username | awk '{print $2}')"
echo

# 确认继续
read -p "是否继续构建和推送镜像？ (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "已取消操作"
    exit 1
fi

# 构建镜像
echo "开始构建镜像..."
docker build -t "${IMAGE_NAME}" .

if [ $? -ne 0 ]; then
    echo "错误: 镜像构建失败"
    exit 1
fi

echo "✓ 镜像构建成功"

# 推送镜像
echo "开始推送镜像到Docker Hub..."
docker push "${IMAGE_NAME}"

if [ $? -ne 0 ]; then
    echo "错误: 镜像推送失败"
    exit 1
fi

echo "✓ 镜像推送成功"
echo
echo "=== 操作完成 ==="
echo "镜像已推送到: ${IMAGE_NAME}"
echo "用户可以通过以下命令部署:"
echo "  docker pull ${IMAGE_NAME}"
echo "  docker compose -f docker-compose.hub.yml up -d"
echo
echo "或者下载docker-compose.hub.yml文件后:"
echo "  docker compose up -d"