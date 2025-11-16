#!/bin/bash
#
# 快速设置脚本 - Translator MCP Server
# 用于初始化项目环境和配置
#

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 打印欢迎信息
echo ""
echo "========================================="
echo " Translator MCP Server - 快速设置"
echo "========================================="
echo ""

# 检查必需的依赖
info "检查系统依赖..."

if ! command_exists node; then
    error "Node.js 未安装。请先安装 Node.js >= 18.0.0"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    error "Node.js 版本过低 (当前: $(node -v))。需要 >= 18.0.0"
    exit 1
fi
success "Node.js 版本: $(node -v)"

if ! command_exists npm; then
    error "npm 未安装"
    exit 1
fi
success "npm 版本: $(npm -v)"

if command_exists docker; then
    success "Docker 已安装: $(docker -v | cut -d',' -f1)"
    DOCKER_AVAILABLE=true
else
    warn "Docker 未安装（可选，但推荐用于生产部署）"
    DOCKER_AVAILABLE=false
fi

echo ""

# 安装依赖
info "安装 npm 依赖..."
npm install
success "依赖安装完成"

echo ""

# 配置环境变量
if [ ! -f ".env" ]; then
    info "创建 .env 配置文件..."
    cp .env.example .env
    success ".env 文件已创建"

    echo ""
    warn "请编辑 .env 文件并填入您的 API 配置："
    echo ""
    echo "  必需配置："
    echo "    - TRANSLATION_API_KEY: 您的 API 密钥"
    echo "    - TRANSLATION_MODEL: 使用的模型名称"
    echo "    - TRANSLATION_BASE_URL: API 端点 URL"
    echo ""
    echo "  OpenRouter 示例："
    echo "    TRANSLATION_API_KEY=sk-or-v1-xxxxx"
    echo "    TRANSLATION_MODEL=anthropic/claude-3.5-sonnet"
    echo "    TRANSLATION_BASE_URL=https://openrouter.ai/api/v1"
    echo ""

    read -p "是否现在编辑 .env 文件? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} .env
    fi
else
    success ".env 文件已存在"
fi

echo ""

# 构建项目
info "构建 TypeScript 项目..."
npm run build
success "构建完成"

echo ""

# Docker 相关设置
if [ "$DOCKER_AVAILABLE" = true ]; then
    read -p "是否构建 Docker 镜像? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "构建 Docker 镜像..."
        docker build -t translator-mcp-server:latest .
        success "Docker 镜像构建完成"
    fi
fi

echo ""
echo "========================================="
success "设置完成！"
echo "========================================="
echo ""
echo "下一步："
echo ""
echo "  1. 确保 .env 文件已正确配置"
echo "  2. 运行开发服务器:"
echo "     npm run dev"
echo ""
if [ "$DOCKER_AVAILABLE" = true ]; then
    echo "  或使用 Docker:"
    echo "     docker-compose up -d"
    echo ""
fi
echo "  3. 验证服务:"
    echo "     curl http://localhost:3031/health"
echo ""
echo "详细文档: docs/DEPLOYMENT.md"
echo ""
