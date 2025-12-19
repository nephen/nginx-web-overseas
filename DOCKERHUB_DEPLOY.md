# Docker Hub部署说明

## 快速部署（用户）

### 1. 创建部署目录
```bash
mkdir nginx-proxy && cd nginx-proxy
```

### 2. 下载部署文件
```bash
# 下载docker-compose文件
curl -o docker-compose.yml https://raw.githubusercontent.com/nephen/nginx-web-overseas/main/docker-compose.hub.yml

# 下载环境变量示例
curl -o .env.example https://raw.githubusercontent.com/nephen/nginx-web-overseas/main/.env.example
```

### 3. 配置环境
```bash
# 复制环境变量文件
cp .env.example .env

# 编辑配置文件（必须修改域名和邮箱）
nano .env
```

### 4. 启动服务
```bash
docker compose up -d
```

### 5. 查看状态
```bash
# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f
```

## 镜像构建（开发者）

### 手动构建
```bash
# 克隆仓库
git clone https://github.com/nephen/nginx-web-overseas.git
cd nginx-web-overseas

# 构建并推送（需要Docker Hub账号）
./build-and-push.sh your-username
```

### 自动构建
推送代码到main分支，GitHub Actions会自动构建并推送镜像。

## 注意事项

1. **替换用户名**：将 `your-username` 替换为你的Docker Hub用户名
2. **GitHub仓库**：更新URL中的GitHub用户名和仓库名
3. **镜像标签**：默认使用`latest`标签，也可以指定版本号
4. **配置文件**：用户必须修改`.env`文件中的域名和邮箱

## 文件说明

- `docker-compose.hub.yml`: 使用Docker Hub镜像的部署配置
- `build-and-push.sh`: 手动构建和推送脚本
- `.github/workflows/docker-build.yml`: 自动构建配置