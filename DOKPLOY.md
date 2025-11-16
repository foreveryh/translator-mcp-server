# Dokploy 部署配置指南

本文档提供在 Dokploy 中部署 Translator MCP Server 的完整配置说明。

## 📋 Dokploy UI 环境变量配置

### 必需环境变量 ⚠️

这些变量**必须**在 Dokploy 的环境变量设置中配置：

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `TRANSLATION_API_KEY` | 翻译 API 的密钥 | `sk-or-v1-xxxxxxxxxxxxxxxx` |
| `TRANSLATION_MODEL` | 使用的模型名称 | `anthropic/claude-3.5-sonnet` |
| `TRANSLATION_BASE_URL` | API 端点 URL | `https://openrouter.ai/api/v1` |

### 可选环境变量 ⚙️

这些变量有默认值，可根据需要覆盖：

| 变量名 | 说明 | 默认值 | 可选值 |
|--------|------|--------|--------|
| `MODE` | 服务器运行模式 | `sse` | `stdio`, `sse`, `rest` |
| `HOST_PORT` | 宿主机端口（通常不需要配置） | `3031` | 任意可用端口 |

### 系统环境变量（自动设置）

这些变量在 docker-compose.yml 中已硬编码，**不需要**在 Dokploy UI 中配置：

| 变量名 | 值 | 说明 |
|--------|-----|------|
| `NODE_ENV` | `production` | Node.js 运行环境 |
| `PORT` | `3031` | 容器内监听端口 |

---

## 🔧 配置示例

### OpenRouter（推荐）

```env
TRANSLATION_API_KEY=sk-or-v1-your-api-key-here
TRANSLATION_MODEL=anthropic/claude-3.5-sonnet
TRANSLATION_BASE_URL=https://openrouter.ai/api/v1
MODE=sse
```

**其他可用模型：**
- `anthropic/claude-3-opus` - 最强性能
- `openai/gpt-4-turbo` - OpenAI 最新模型
- `google/gemini-pro` - Google Gemini
- `meta-llama/llama-3.1-70b-instruct` - 开源 Llama

---

### OpenAI

```env
TRANSLATION_API_KEY=sk-proj-your-api-key-here
TRANSLATION_MODEL=gpt-4-turbo
TRANSLATION_BASE_URL=https://api.openai.com/v1
MODE=sse
```

---

### DeepSeek

```env
TRANSLATION_API_KEY=sk-your-api-key-here
TRANSLATION_MODEL=deepseek-chat
TRANSLATION_BASE_URL=https://api.deepseek.com/v1
MODE=sse
```

---

### 自定义 OpenAI 兼容 API

```env
TRANSLATION_API_KEY=your-api-key
TRANSLATION_MODEL=your-model-name
TRANSLATION_BASE_URL=https://your-api-endpoint.com/v1
MODE=sse
```

---

## 🌐 Dokploy 部署步骤

### 1. 在 Dokploy UI 中创建应用

- **应用类型：** Docker Compose
- **Git 仓库：** `https://github.com/foreveryh/translator-mcp-server`
- **分支：** `main`（或您的目标分支）
- **Compose 文件路径：** `docker-compose.yml`

### 2. 配置环境变量

在 Dokploy 的 "Environment Variables" 部分添加：

```
TRANSLATION_API_KEY=sk-or-v1-xxxxxxxxxxxxx
TRANSLATION_MODEL=anthropic/claude-3.5-sonnet
TRANSLATION_BASE_URL=https://openrouter.ai/api/v1
MODE=sse
```

⚠️ **安全提醒：** 不要把 API 密钥提交到 Git 仓库中！

### 3. 配置域名和反向代理

在 Dokploy 的 "Domains" 部分：

- **域名：** `t.deeptoai.com`
- **容器端口：** `3031`
- **协议：** `HTTP`（Dokploy 会自动处理 HTTPS）

Dokploy 会自动：
- 配置 Nginx/Traefik 反向代理
- 申请 SSL 证书（Let's Encrypt）
- 设置 HTTPS 重定向

### 4. 部署

点击 "Deploy" 按钮，Dokploy 会：
1. 从 Git 拉取代码
2. 构建 Docker 镜像
3. 启动容器
4. 配置反向代理
5. 申请 SSL 证书

### 5. 验证部署

访问以下 URL 验证服务：

```bash
# 健康检查
curl https://t.deeptoai.com/health

# 应返回
{"status":"healthy","version":"0.1.0"}
```

---

## 🔍 端口配置说明

### 容器内部端口（固定）
- **端口：** `3031`
- **说明：** Node.js 应用监听的端口，**不可修改**
- **位置：** Dockerfile 和 docker-compose.yml 中硬编码

### 宿主机端口（可选配置）
- **环境变量：** `HOST_PORT`
- **默认值：** `3031`
- **说明：** 容器映射到宿主机的端口

**使用反向代理时（Dokploy）：**
- ✅ **不需要关心宿主机端口**
- Dokploy 会自动处理端口映射
- 通过域名访问：`https://t.deeptoai.com`
- 反向代理转发到容器的 `3031` 端口

**直接访问时（不推荐）：**
```bash
# 如果 HOST_PORT=8080
curl http://your-server-ip:8080/health
```

---

## 🔒 安全建议

### 1. 使用环境变量管理敏感信息
- ✅ 在 Dokploy UI 中配置环境变量
- ❌ 不要硬编码 API 密钥
- ❌ 不要提交 `.env` 文件到 Git

### 2. 限制访问（可选）

如果需要限制访问，可以在 Dokploy 或 Nginx 层面添加：
- IP 白名单
- HTTP Basic Auth
- API Token 认证

### 3. 监控和日志

Dokploy 提供：
- 实时日志查看
- 资源使用监控
- 健康检查状态

---

## 📊 资源配置建议

Dokploy 会自动管理资源，但您可以根据需要调整：

**推荐配置：**
- **CPU：** 0.5 - 1.0 核心
- **内存：** 256MB - 512MB
- **存储：** 1GB（Docker 镜像 + 日志）

**高负载配置：**
- **CPU：** 1.0 - 2.0 核心
- **内存：** 512MB - 1GB

---

## 🐛 故障排查

### 容器无法启动

**检查步骤：**
1. 查看 Dokploy 日志
2. 确认环境变量已正确设置
3. 检查 API 密钥是否有效

### 健康检查失败

```bash
# 进入容器检查
docker exec -it <container-id> sh

# 测试内部端点
wget -O- http://localhost:3031/health
```

### API 请求失败

```bash
# 测试 API 连接
curl -H "Authorization: Bearer $TRANSLATION_API_KEY" \
  $TRANSLATION_BASE_URL/models
```

### 域名无法访问

1. 检查 DNS 是否正确指向服务器
2. 确认 Dokploy 反向代理配置
3. 检查防火墙规则（80, 443 端口）

---

## 📞 支持

如遇问题：
1. 查看 Dokploy 日志
2. 查看容器日志
3. 参考 [部署文档](docs/DEPLOYMENT.md)
4. 提交 [GitHub Issue](https://github.com/foreveryh/translator-mcp-server/issues)

---

## ✅ 部署检查清单

部署前确认：
- [ ] Git 仓库可访问
- [ ] 环境变量已配置（API_KEY, MODEL, BASE_URL）
- [ ] 域名 DNS 已指向服务器
- [ ] Dokploy 可以拉取代码

部署后验证：
- [ ] 容器状态为 running
- [ ] 健康检查通过
- [ ] 域名可以访问
- [ ] SSL 证书已自动配置
- [ ] 翻译功能正常工作
