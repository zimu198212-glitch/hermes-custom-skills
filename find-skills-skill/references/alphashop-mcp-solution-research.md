# Alphashop MCP 问题研究：skill搜索 vs 信息搜索

## 核心区分

| 任务 | 工具 | 触发条件 |
|------|------|---------|
| 搜索/安装 skill | `find-skills-skill` (search-all.sh) | "搜xxx skill"、"安装skill"、"有哪些skill" |
| 研究问题/找解决方案 | `web_search_plus` | "为什么不能用"、"怎么解决"、"服务宕机"、"错误码" |

**两者职责互斥，绝对不能混用。**

## 当前状态（2026-05-18）

Alphashop MCP SSE `/sse?key=<JWT>` 返回 HTTP 200 + `Content-Length: 0`，服务端未发送任何 EventStream 数据。所有端点（POST/GET）均返回空响应。

### 测试过的传输方式

| 传输 | 端点 | 结果 | 错误 |
|------|------|------|------|
| MCP Python SDK `sse_client` | `/sse?key=<JWT>` | ❌ | `SSEError: Expected text/event-stream, got ''` |
| MCP Python SDK `sse_client` | `/sse` + Auth header | ❌ | `SSEError: Expected text/event-stream, got application/json` |
| MCP Python SDK `streamable_http_client` | `/mcp` | ❌ | `Unexpected content type: text/html` + timeout |
| 标准 `httpx` GET | `/mcp?key=` | ✅连接 | 302 redirect to wrongpage.html |
| 标准 `httpx` GET | `/api/sse` | ❌ | 302 → 1688 wrongpage |
| 直接 `curl` | `/sse?key=<JWT>` | ✅HTTP 200 | Content-Length: 0，空body |

### 已排除的原因

- ❌ JWT 格式问题（`iat`/`jti`/`nbf` 均已补全）
- ❌ Accept header 缺失（显式传入 `text/event-stream`）
- ❌ Token 过期（30分钟生命周期，测试时均在有效期内）
- ❌ DNS/TCP 连接问题（HTTP 200 建立成功）
- ❌ 多路复用问题（单连接测试同样失败）
- ❌ 认证方式问题（param/header/Bearer header 均试过）

### 根因判定

**服务端问题**：`mcp.alphashop.cn` 的 MCP Handler 未正确实现或已下线。`Content-Length: 0` 说明服务端收到了请求但没有任何响应输出。

### 调试命令

```bash
# 生成 JWT token
TOKEN=$(node -e "const auth=require('$(npm root -g)/1688alphaclaw/lib/auth.js'); console.log(auth.generateAuthHeader('AK','SK',1800))")

# 基本连接测试
curl -sI "https://mcp.alphashop.cn/sse?key=${TOKEN}" -H "Accept: text/event-stream"

# 用 MCP Python SDK 测试（需先 pip install mcp）
python3.15 -c "
from mcp.client.sse import sse_client
import asyncio
async with sse_client(url, headers={'Accept':'text/event-stream'}, timeout=5) as streams:
    read, write = streams
    # ...
"
```

### 搜索结果

网上无 `mcp.alphashop.cn` 的配置案例或相同问题报告。OpenClaw 用户能连接可能是不同服务端节点或旧版 API。
