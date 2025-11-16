# 发布到 npm 指南

本文档介绍如何将 translator-mcp-server 发布到 npm。

## 📋 发布前检查清单

### 1. 确保代码质量

```bash
# 运行测试（如果有）
npm test

# 代码检查
npm run lint

# 构建测试
npm run build
```

### 2. 更新版本号

根据语义化版本规范（SemVer）更新版本：

- **补丁版本**（bug 修复）：`0.1.0` → `0.1.1`
  ```bash
  npm version patch
  ```

- **次要版本**（新功能，向后兼容）：`0.1.0` → `0.2.0`
  ```bash
  npm version minor
  ```

- **主要版本**（破坏性更改）：`0.1.0` → `1.0.0`
  ```bash
  npm version major
  ```

### 3. 检查 package.json 配置

确认以下字段配置正确：

```json
{
  "name": "translator-mcp-server",
  "version": "0.1.0",
  "description": "...",
  "author": "foreveryh",
  "license": "Apache-2.0",
  "repository": {
    "type": "git",
    "url": "https://github.com/foreveryh/translator-mcp-server.git"
  },
  "bin": {
    "translator-mcp": "dist/index.js"
  },
  "main": "dist/index.js",
  "files": [
    "dist",
    "README.md",
    "LICENSE",
    ".env.example"
  ]
}
```

## 🚀 发布步骤

### 首次发布

#### 1. 登录 npm

```bash
npm login
```

输入您的 npm 账号信息：
- Username
- Password
- Email
- One-time password (如果启用了 2FA)

验证登录：
```bash
npm whoami
```

#### 2. 检查包名是否可用

```bash
npm search translator-mcp-server
```

如果包名已被占用，需要在 `package.json` 中更改包名。

可选包名建议：
- `@yourusername/translator-mcp-server`（作用域包）
- `translator-mcp`
- `mcp-translator-server`

#### 3. 发布到 npm

**发布为公开包：**
```bash
npm publish --access public
```

**如果使用作用域包（@yourusername/package）：**
```bash
# 首次发布需要指定 --access public
npm publish --access public

# 后续更新可以直接
npm publish
```

#### 4. 验证发布

访问 npm 页面查看：
```
https://www.npmjs.com/package/translator-mcp-server
```

或安装测试：
```bash
npx translator-mcp-server@latest
```

### 后续版本发布

#### 1. 更新代码并提交

```bash
git add .
git commit -m "feat: add new feature"
git push
```

#### 2. 更新版本号

```bash
# 根据变更类型选择
npm version patch   # 0.1.0 -> 0.1.1
npm version minor   # 0.1.0 -> 0.2.0
npm version major   # 0.1.0 -> 1.0.0
```

这会自动：
- 更新 `package.json` 中的版本号
- 创建一个 git commit
- 创建一个 git tag

#### 3. 推送 tag 到 GitHub

```bash
git push --tags
```

#### 4. 发布新版本

```bash
npm publish
```

## 📦 发布后使用方式

用户可以通过以下方式使用您的 MCP 服务器：

### 方式 1：npx 直接运行（推荐）

**Claude Desktop 配置：**
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

### 方式 2：全局安装

```bash
npm install -g translator-mcp-server
```

**使用：**
```bash
translator-mcp
```

### 方式 3：项目依赖

```bash
npm install translator-mcp-server
```

**使用：**
```bash
npx translator-mcp
```

## 🔧 测试本地包（发布前）

在发布前，可以在本地测试包：

### 1. 创建本地链接

```bash
cd /path/to/translator-mcp-server
npm run build
npm link
```

### 2. 在其他项目中使用

```bash
cd /path/to/test-project
npm link translator-mcp-server
```

### 3. 测试命令

```bash
translator-mcp --help
```

### 4. 取消链接

```bash
npm unlink -g translator-mcp-server
```

## 📊 版本管理策略

### 语义化版本（SemVer）

版本格式：`MAJOR.MINOR.PATCH`

- **MAJOR**：不兼容的 API 修改
- **MINOR**：向下兼容的功能性新增
- **PATCH**：向下兼容的问题修正

### 版本标签

可以使用标签发布特殊版本：

```bash
# Beta 版本
npm version 0.2.0-beta.0
npm publish --tag beta

# Alpha 版本
npm version 0.2.0-alpha.0
npm publish --tag alpha

# 用户安装
npm install translator-mcp-server@beta
```

## 🔒 安全建议

### 1. 启用 2FA (Two-Factor Authentication)

在 npm 网站上启用 2FA：
```
https://www.npmjs.com/settings/yourusername/tfa
```

### 2. 使用 .npmrc 保护凭证

不要将 `.npmrc` 文件提交到 Git：
```bash
echo ".npmrc" >> .gitignore
```

### 3. 检查发布内容

发布前查看将要发布的文件：
```bash
npm pack --dry-run
```

或：
```bash
npm publish --dry-run
```

## 📝 更新 README.md

发布后，确保 README 中包含安装说明：

```markdown
## Installation

\`\`\`bash
npm install -g translator-mcp-server
# or use with npx
npx translator-mcp-server
\`\`\`

## Usage in Claude Desktop

\`\`\`json
{
  "mcpServers": {
    "translator": {
      "command": "npx",
      "args": ["-y", "translator-mcp-server"],
      "env": {
        "TRANSLATION_API_KEY": "your-key"
      }
    }
  }
}
\`\`\`
```

## 🎯 发布检查清单

- [ ] 代码已提交并推送到 GitHub
- [ ] 所有测试通过
- [ ] 版本号已更新
- [ ] CHANGELOG.md 已更新（如果有）
- [ ] README.md 包含安装和使用说明
- [ ] LICENSE 文件存在
- [ ] .env.example 文件存在
- [ ] npm login 成功
- [ ] 包名检查无冲突
- [ ] 执行 `npm publish --dry-run` 检查
- [ ] 发布成功后验证安装

## 🔄 自动化发布（可选）

可以使用 GitHub Actions 自动发布：

创建 `.github/workflows/publish.yml`：

```yaml
name: Publish to npm

on:
  release:
    types: [created]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'
      - run: npm ci
      - run: npm run build
      - run: npm publish --access public
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

需要在 GitHub 仓库设置中添加 `NPM_TOKEN` secret。

## 📞 问题排查

### 包名已存在

```bash
npm ERR! 403 Forbidden - PUT https://registry.npmjs.org/translator-mcp-server
```

解决：更改 package.json 中的包名

### 权限不足

```bash
npm ERR! 403 Forbidden
```

解决：
1. 检查是否已登录：`npm whoami`
2. 重新登录：`npm login`
3. 检查包名是否被他人占用

### 发布内容不正确

查看将要发布的文件：
```bash
npm pack
tar -tzf translator-mcp-server-0.1.0.tgz
```

## 🎉 发布完成

发布成功后：

1. ✅ 在 [npmjs.com](https://www.npmjs.com) 查看包页面
2. ✅ 更新 GitHub README 添加 npm 徽章
3. ✅ 创建 GitHub Release
4. ✅ 在社区分享您的 MCP 服务器

恭喜！🚀
