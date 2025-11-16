# Translator MCP Server

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![npm version](https://img.shields.io/npm/v/translator-mcp-server.svg)](https://www.npmjs.com/package/translator-mcp-server)

专业翻译 MCP 服务器，基于三阶段翻译流程（分析规划、分段翻译、全文审校），提供高精度翻译服务。MCP（Model Context Protocol）是一种标准协议，允许 AI 助手（如 Claude）与外部服务进行结构化交互。

**🌐 在线服务地址：** `https://t.deeptoai.com/sse`

## 专业翻译优势

- **三阶段翻译流程**：分析规划、分段翻译、全文审校，确保专业领域文档的翻译质量
- **领域术语识别**：自动识别专业文本领域，提取关键术语并确保术语一致性
- **质量评估系统**：提供全面翻译质量评估，包括准确性、流畅性、术语使用和风格一致性
- **多语言支持**：支持中文、英文、日语、韩语、法语、德语等多种语言互译
- **风格与格式保持**：根据文本类型自动调整翻译风格，保持原文的专业性和表达方式

## 适用场景

- **技术文档翻译**：软件文档、API文档、技术规范等专业内容翻译
- **学术论文翻译**：确保学术术语准确，保持学术文体风格
- **法律文件翻译**：保证法律术语准确性和表述精确性
- **医疗资料翻译**：专业医学术语翻译和医疗文献本地化
- **金融报告翻译**：准确翻译金融术语和复杂财务概念

## 快速开始

### 方式 1：使用在线服务（推荐）

直接使用已部署的在线服务，无需安装：

**Claude Desktop 配置：**

macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "translator": {
      "url": "https://t.deeptoai.com/sse",
      "transport": "sse"
    }
  }
}
```

配置完成后，重启 Claude Desktop 即可使用翻译功能。

### 方式 2：本地运行

#### 通过 npm（推荐）

```bash
# 使用 npx 直接运行
npx translator-mcp-server

# 或全局安装
npm install -g translator-mcp-server
translator-mcp
```

**Claude Desktop 本地配置：**

```json
{
  "mcpServers": {
    "translator": {
      "command": "npx",
      "args": ["-y", "translator-mcp-server"],
      "env": {
        "TRANSLATION_API_KEY": "your-api-key",
        "TRANSLATION_MODEL": "glm-4-flash",
        "TRANSLATION_BASE_URL": "https://open.bigmodel.cn/api/paas/v4"
      }
    }
  }
}
```

#### 从源码运行

```bash
# 1. 克隆仓库
git clone https://github.com/foreveryh/translator-mcp-server
cd translator-mcp-server

# 2. 安装依赖
npm install

# 3. 配置环境变量
cp .env.example .env
# 编辑 .env 填入您的 API 配置

# 4. 构建并运行
npm run build
npm start
```

## 环境变量配置

创建 `.env` 文件或设置以下环境变量：

```bash
# 翻译 API 配置（必需）
TRANSLATION_API_KEY=your_api_key          # API 密钥
TRANSLATION_MODEL=glm-4-flash             # 模型名称
TRANSLATION_BASE_URL=https://open.bigmodel.cn/api/paas/v4  # API 端点

# 服务器配置（可选）
MODE=sse              # 运行模式：stdio, sse, rest
PORT=3031             # 服务器端口
```

### 支持的 AI 服务商

#### 智谱 AI（推荐）
```bash
TRANSLATION_API_KEY=your-zhipu-key
TRANSLATION_MODEL=glm-4-flash
TRANSLATION_BASE_URL=https://open.bigmodel.cn/api/paas/v4
```

#### OpenRouter
```bash
TRANSLATION_API_KEY=sk-or-v1-xxxxx
TRANSLATION_MODEL=anthropic/claude-3.5-sonnet
TRANSLATION_BASE_URL=https://openrouter.ai/api/v1
```

#### OpenAI
```bash
TRANSLATION_API_KEY=sk-proj-xxxxx
TRANSLATION_MODEL=gpt-4-turbo
TRANSLATION_BASE_URL=https://api.openai.com/v1
```

## MCP工具接口

服务器提供以下MCP标准工具:

### 1. 翻译工具 (translate_text)

专业级文本翻译，自动适应不同领域和文体风格。

**参数:**
- `text`: 需要翻译的源文本
- `target_language`: 目标语言代码 (如'zh'、'en'、'ja'等)
- `source_language`: (可选)源语言代码
- `high_quality`: (可选)是否启用高精度翻译流程，默认为true

**使用场景:**
- 设置`high_quality=true`用于专业文档、学术论文等对精度要求高的场景
- 设置`high_quality=false`用于非正式内容或需要快速翻译的场景

### 2. 翻译质量评估工具 (evaluate_translation)

对翻译结果进行全面质量评估，提供详细反馈。

**参数:**
- `original_text`: 原始文本
- `translated_text`: 翻译后的文本
- `detailed_feedback`: (可选)是否提供详细反馈，默认为false

**评估指标:**
- 准确性：译文是否准确传达原文意思
- 流畅性：译文是否符合目标语言表达习惯
- 术语使用：专业术语翻译的准确性和一致性
- 风格一致性：译文是否保持原文风格

### 资源接口

- **supported_languages**: 支持的语言列表
  - URI: `languages://list`

## 与AI助手集成

本服务器设计为与支持MCP协议的AI助手无缝集成，使AI能够提供专业级翻译服务:

```typescript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { SSEClientTransport } from "@modelcontextprotocol/sdk/client/sse.js";

// 连接到MCP服务器
const transport = new SSEClientTransport("https://t.deeptoai.com/sse");
const client = new Client(
  { name: "assistant-client", version: "1.0.0" },
  { capabilities: { tools: {} } }
);
await client.connect(transport);

// 调用专业翻译工具
const result = await client.callTool({
  name: "translate_text",
  arguments: {
    text: "The mitochondrion is the powerhouse of the cell.",
    target_language: "zh",
    high_quality: true
  }
});

console.log(result.content[0].text);
```

## MCP 客户端配置

### Claude Desktop（推荐）

配置文件位置：
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

**使用在线服务：**
```json
{
  "mcpServers": {
    "translator": {
      "url": "https://t.deeptoai.com/sse",
      "transport": "sse"
    }
  }
}
```

**使用本地服务（stdio 模式）：**
```json
{
  "mcpServers": {
    "translator": {
      "command": "npx",
      "args": ["-y", "translator-mcp-server"],
      "env": {
        "TRANSLATION_API_KEY": "your-key",
        "TRANSLATION_MODEL": "glm-4-flash",
        "TRANSLATION_BASE_URL": "https://open.bigmodel.cn/api/paas/v4",
        "MODE": "stdio"
      }
    }
  }
}
```

配置完成后，重启 Claude Desktop，即可使用 `translate_text` 和 `evaluate_translation` 工具。

### Claude Code（Cline）

**注意：** Claude Code 仅支持 stdio 模式，不支持远程 SSE 连接。

配置文件：工作区根目录 `.claude/mcp.json` 或全局 `~/.config/cline/mcp.json`

```json
{
  "mcpServers": {
    "translator": {
      "command": "npx",
      "args": ["-y", "translator-mcp-server"],
      "env": {
        "TRANSLATION_API_KEY": "your-key",
        "TRANSLATION_MODEL": "glm-4-flash",
        "TRANSLATION_BASE_URL": "https://open.bigmodel.cn/api/paas/v4"
      }
    }
  }
}
```

### Cursor / 其他 MCP 客户端

参考 Claude Desktop 的 SSE 配置方式，URL 设置为 `https://t.deeptoai.com/sse`。

## Docker 部署

### Docker Compose 部署（推荐）

```bash
# 1. 克隆仓库
git clone https://github.com/foreveryh/translator-mcp-server
cd translator-mcp-server

# 2. 创建并配置 .env 文件
cp .env.example .env
# 编辑 .env 填入您的 API 配置

# 3. 启动服务
docker-compose up -d

# 4. 查看日志
docker-compose logs -f

# 5. 测试健康检查
curl http://localhost:3031/health

# 6. 停止服务
docker-compose down
```

### 单独使用 Docker

```bash
# 构建镜像
docker build -t translator-mcp-server .

# 运行容器
docker run -d \
  -p 3031:3031 \
  -e TRANSLATION_API_KEY=your-key \
  -e TRANSLATION_MODEL=glm-4-flash \
  -e TRANSLATION_BASE_URL=https://open.bigmodel.cn/api/paas/v4 \
  -e MODE=sse \
  --name translator-mcp \
  translator-mcp-server

# 查看日志
docker logs -f translator-mcp
```

## 使用示例

### 在 Claude Desktop 中使用

配置完成后，您可以直接在对话中使用翻译功能：

```
请翻译这段文本到中文：
"The mitochondrion is the powerhouse of the cell."
```

或者评估翻译质量：

```
请评估这个翻译的质量：
原文：Hello, world!
译文：你好，世界！
```

### 通过 API 调用

```typescript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { SSEClientTransport } from "@modelcontextprotocol/sdk/client/sse.js";

// 连接到在线服务
const transport = new SSEClientTransport("https://t.deeptoai.com/sse");
const client = new Client(
  { name: "my-app", version: "1.0.0" },
  { capabilities: { tools: {} } }
);
await client.connect(transport);

// 翻译文本
const result = await client.callTool({
  name: "translate_text",
  arguments: {
    text: "Hello, how are you?",
    target_language: "zh",
    high_quality: true
  }
});

console.log(result.content[0].text);
// 输出：你好，你好吗？
```

## 故障排查

### Claude Desktop 无法连接

1. **检查配置文件格式**
   - 确保 JSON 格式正确（无多余逗号、引号匹配）
   - 使用 JSON 验证器检查

2. **重启 Claude Desktop**
   - 完全退出（Cmd+Q / Alt+F4）
   - 重新打开应用

3. **检查在线服务**
   ```bash
   curl https://t.deeptoai.com/health
   # 应返回: {"status":"healthy","version":"0.1.0"}
   ```

4. **查看日志**
   - macOS: `~/Library/Logs/Claude/`
   - Windows: `%APPDATA%\Claude\logs\`

### 翻译速度较慢

三阶段翻译流程需要 3 次 API 调用，适合专业文档翻译。如需快速翻译：

1. **使用简单模式**：设置 `high_quality: false`
2. **选择更快的模型**：如 `glm-4-flash`
3. **检查网络延迟**：测试到 API 端点的连接速度

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

Apache-2.0 License - 详见 [LICENSE](LICENSE) 文件。

## 致谢

基于 [Model Context Protocol](https://modelcontextprotocol.io/) 构建。