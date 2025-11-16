# 构建阶段
FROM node:22.11.0-alpine3.20 AS builder

WORKDIR /app

# 复制 package 文件
COPY package*.json ./

# 安装依赖
RUN npm ci --only=production && \
    npm cache clean --force

# 复制源代码
COPY tsconfig.json ./
COPY src ./src

# 构建应用
RUN npm run build

# 生产阶段
FROM node:22.11.0-alpine3.20 AS production

# 安装 wget（用于健康检查）
RUN apk add --no-cache wget

WORKDIR /app

# 创建非特权用户
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# 设置环境变量
ENV NODE_ENV=production \
    PORT=3031 \
    MODE=sse

# 复制构建产物和依赖
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# 切换到非特权用户
USER nodejs

# 暴露端口
EXPOSE 3031

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/health || exit 1

# 运行应用
CMD ["node", "dist/index.js"]
