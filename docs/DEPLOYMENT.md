# 部署指南

本文档提供详细的部署说明，包括本地开发环境和生产环境部署。

## 目录

- [环境要求](#环境要求)
- [本地开发部署](#本地开发部署)
- [生产环境部署](#生产环境部署)
- [安全配置](#安全配置)
- [常见问题](#常见问题)

---

## 环境要求

### 必需软件

- **Node.js**: >= 18.0.0（推荐 22.x LTS）
- **npm**: >= 9.0.0
- **Docker**: >= 20.10（可选，用于容器化部署）
- **Docker Compose**: >= 2.0（可选）

### API 服务

需要以下任一 OpenAI 兼容 API 服务：

- OpenRouter（推荐，支持多种模型）
- OpenAI
- DeepSeek
- 其他 OpenAI 兼容服务

---

## 本地开发部署

### 方式 1：直接运行（开发模式）

```bash
# 1. 克隆仓库
git clone https://github.com/foreveryh/translator-mcp-server
cd translator-mcp-server

# 2. 安装依赖
npm install

# 3. 配置环境变量
cp .env.example .env

# 编辑 .env 文件，填入您的 API 配置
nano .env  # 或使用其他编辑器

# 4. 启动开发服务器
npm run dev
```

**验证服务运行：**
```bash
# 在新终端窗口执行
curl http://localhost:3031/health
# 应返回: {"status":"healthy","version":"0.1.0"}
```

### 方式 2：使用 Docker（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/foreveryh/translator-mcp-server
cd translator-mcp-server

# 2. 配置环境变量
cp .env.example .env
nano .env  # 填入您的 API 配置

# 3. 使用 Docker Compose 启动
docker-compose up -d

# 4. 查看日志
docker-compose logs -f

# 5. 验证服务
curl http://localhost:3031/health
```

**停止服务：**
```bash
docker-compose down
```

---

## 生产环境部署

### 部署到 t.deeptoai.com（或您的服务器）

#### 步骤 1：服务器准备

```bash
# 登录到您的服务器
ssh user@t.deeptoai.com

# 安装 Docker 和 Docker Compose（如果未安装）
sudo apt update
sudo apt install -y docker.io docker-compose

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户加入 docker 组
sudo usermod -aG docker $USER
# 注销并重新登录以使组权限生效
```

#### 步骤 2：部署应用

```bash
# 克隆仓库
git clone https://github.com/foreveryh/translator-mcp-server
cd translator-mcp-server

# 创建生产环境配置
cp .env.example .env

# 编辑配置文件
nano .env
```

**.env 生产配置示例：**
```bash
NODE_ENV=production
PORT=3031
MODE=sse

# OpenRouter 配置
TRANSLATION_API_KEY=sk-or-v1-YOUR_REAL_API_KEY
TRANSLATION_MODEL=anthropic/claude-3.5-sonnet
TRANSLATION_BASE_URL=https://openrouter.ai/api/v1
```

```bash
# 构建并启动服务
docker-compose up -d

# 查看日志确认运行正常
docker-compose logs -f mcp-server
```

#### 步骤 3：配置反向代理（Nginx）

创建 Nginx 配置文件：

```bash
sudo nano /etc/nginx/sites-available/translator-mcp
```

**Nginx 配置内容：**
```nginx
server {
    listen 80;
    server_name t.deeptoai.com;

    # 重定向到 HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name t.deeptoai.com;

    # SSL 证书（使用 Let's Encrypt）
    ssl_certificate /etc/letsencrypt/live/t.deeptoai.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/t.deeptoai.com/privkey.pem;

    # SSL 安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # SSE 端点
    location /sse {
        proxy_pass http://localhost:3031/sse;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # SSE 特定配置
        proxy_buffering off;
        proxy_cache off;
        proxy_read_timeout 86400;
    }

    # 消息端点
    location /messages {
        proxy_pass http://localhost:3031/messages;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 健康检查端点
    location /health {
        proxy_pass http://localhost:3031/health;
        access_log off;
    }
}
```

**启用配置：**
```bash
sudo ln -s /etc/nginx/sites-available/translator-mcp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 步骤 4：配置 SSL 证书（Let's Encrypt）

```bash
# 安装 Certbot
sudo apt install -y certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d t.deeptoai.com

# 设置自动续期
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

#### 步骤 5：验证部署

```bash
# 测试 HTTPS 连接
curl https://t.deeptoai.com/health

# 应返回
# {"status":"healthy","version":"0.1.0"}
```

---

## 安全配置

### 1. 防火墙配置

```bash
# 安装 UFW
sudo apt install -y ufw

# 配置规则
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 启用防火墙
sudo ufw enable
sudo ufw status
```

### 2. 添加认证保护（可选但推荐）

在生产环境中，建议添加 API Token 认证。可以通过修改 Nginx 配置添加基本认证：

```bash
# 安装 htpasswd 工具
sudo apt install -y apache2-utils

# 创建密码文件
sudo htpasswd -c /etc/nginx/.htpasswd translator_user
```

在 Nginx 配置中添加：
```nginx
location /sse {
    auth_basic "Translator MCP Server";
    auth_basic_user_file /etc/nginx/.htpasswd;
    # ... 其他配置
}
```

### 3. 限流配置

在 Nginx 配置中添加：
```nginx
# 在 http 块中添加
limit_req_zone $binary_remote_addr zone=translator_limit:10m rate=10r/s;

# 在 location 块中添加
limit_req zone=translator_limit burst=20 nodelay;
```

---

## 监控和维护

### 日志查看

```bash
# Docker 日志
docker-compose logs -f mcp-server

# 查看最近 100 行
docker-compose logs --tail=100 mcp-server

# Nginx 日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 性能监控

```bash
# 查看容器资源使用
docker stats translator-mcp

# 查看系统资源
htop
```

### 更新部署

```bash
cd /path/to/translator-mcp-server

# 拉取最新代码
git pull origin main

# 重新构建并启动
docker-compose down
docker-compose build
docker-compose up -d

# 查看日志确认
docker-compose logs -f
```

---

## 常见问题

### Q: 容器无法启动

**检查步骤：**
```bash
# 查看容器状态
docker-compose ps

# 查看详细日志
docker-compose logs mcp-server

# 检查环境变量
docker-compose config
```

### Q: API 请求失败

**可能原因：**
1. API 密钥配置错误
2. API 配额耗尽
3. 网络连接问题

**检查方法：**
```bash
# 进入容器
docker exec -it translator-mcp sh

# 测试 API 连接
wget -O- --header="Authorization: Bearer $TRANSLATION_API_KEY" \
  $TRANSLATION_BASE_URL/models
```

### Q: 健康检查失败

```bash
# 检查服务是否运行
curl http://localhost:3031/health

# 检查端口是否被占用
sudo lsof -i :3031

# 重启服务
docker-compose restart
```

### Q: SSL 证书问题

```bash
# 检查证书状态
sudo certbot certificates

# 手动续期
sudo certbot renew

# 测试续期
sudo certbot renew --dry-run
```

---

## 支持

如有问题，请：
1. 查看 [README.md](../README.md)
2. 查看 [GitHub Issues](https://github.com/foreveryh/translator-mcp-server/issues)
3. 联系项目维护者
