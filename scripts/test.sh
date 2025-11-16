#!/bin/bash
#
# 测试脚本 - Translator MCP Server
# 用于验证服务是否正常运行
#

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

fail() {
    echo -e "${RED}[✗]${NC} $1"
}

# 默认配置
HOST="${HOST:-localhost}"
PORT="${PORT:-3031}"
BASE_URL="http://${HOST}:${PORT}"

echo ""
echo "========================================="
echo " Translator MCP Server - 服务测试"
echo "========================================="
echo ""
info "测试目标: $BASE_URL"
echo ""

# 测试计数
TESTS_PASSED=0
TESTS_FAILED=0

# 测试 1: 健康检查
info "测试 1/4: 健康检查端点..."
if curl -f -s "${BASE_URL}/health" > /dev/null; then
    RESPONSE=$(curl -s "${BASE_URL}/health")
    if echo "$RESPONSE" | grep -q "healthy"; then
        success "健康检查通过: $RESPONSE"
        ((TESTS_PASSED++))
    else
        fail "健康检查返回异常: $RESPONSE"
        ((TESTS_FAILED++))
    fi
else
    fail "无法访问健康检查端点"
    ((TESTS_FAILED++))
fi

echo ""

# 测试 2: SSE 端点是否可访问
info "测试 2/4: SSE 端点可访问性..."
if curl -f -s -I "${BASE_URL}/sse" > /dev/null 2>&1; then
    success "SSE 端点可访问"
    ((TESTS_PASSED++))
else
    fail "SSE 端点无法访问"
    ((TESTS_FAILED++))
fi

echo ""

# 测试 3: 检查 Docker 容器状态（如果使用 Docker）
info "测试 3/4: Docker 容器状态..."
if command -v docker >/dev/null 2>&1; then
    if docker ps | grep -q translator-mcp; then
        CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' translator-mcp 2>/dev/null)
        if [ "$CONTAINER_STATUS" = "running" ]; then
            success "Docker 容器运行中"

            # 检查容器用户
            CONTAINER_USER=$(docker exec translator-mcp whoami 2>/dev/null)
            if [ "$CONTAINER_USER" = "nodejs" ]; then
                success "容器以非 root 用户运行: $CONTAINER_USER"
            else
                fail "容器以 root 用户运行 (安全风险)"
            fi
            ((TESTS_PASSED++))
        else
            fail "Docker 容器未运行: $CONTAINER_STATUS"
            ((TESTS_FAILED++))
        fi
    else
        info "未找到 Docker 容器（可能使用直接运行模式）"
        ((TESTS_PASSED++))
    fi
else
    info "Docker 未安装（跳过 Docker 测试）"
    ((TESTS_PASSED++))
fi

echo ""

# 测试 4: 端口监听检查
info "测试 4/4: 端口监听状态..."
if command -v lsof >/dev/null 2>&1; then
    if sudo lsof -i :${PORT} > /dev/null 2>&1; then
        success "端口 ${PORT} 正在监听"
        ((TESTS_PASSED++))
    else
        fail "端口 ${PORT} 未被监听"
        ((TESTS_FAILED++))
    fi
elif command -v netstat >/dev/null 2>&1; then
    if netstat -tuln | grep -q ":${PORT}"; then
        success "端口 ${PORT} 正在监听"
        ((TESTS_PASSED++))
    else
        fail "端口 ${PORT} 未被监听"
        ((TESTS_FAILED++))
    fi
else
    info "无法检测端口状态（lsof 和 netstat 都未安装）"
    ((TESTS_PASSED++))
fi

echo ""
echo "========================================="
echo " 测试结果"
echo "========================================="
echo ""
echo -e "通过: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "失败: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    success "所有测试通过！服务运行正常 ✨"
    echo ""
    echo "您可以："
    echo "  - 在 Claude Desktop 中配置使用: https://t.deeptoai.com/sse"
    echo "  - 查看日志: docker-compose logs -f"
    echo "  - 停止服务: docker-compose down"
    exit 0
else
    fail "部分测试失败，请检查日志"
    echo ""
    echo "调试建议:"
    echo "  - 查看日志: docker-compose logs mcp-server"
    echo "  - 检查配置: cat .env"
    echo "  - 重启服务: docker-compose restart"
    exit 1
fi
