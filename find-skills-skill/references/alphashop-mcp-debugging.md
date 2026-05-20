# Alphashop MCP SSE 调试笔记（2026-05-18）

## 背景

Alphashop（遨虾）提供 1688 官方 AI 数据 API，通过 MCP SSE 协议暴露工具。
MCP endpoint: `https://mcp.alphashop.cn/sse`

## 问题现象

| 通道 | 响应 |
|------|------|
| `mcp.alphashop.cn/sse` | HTTP 200 + Content-Length: 0（无任何 EventStream 数据）|
| `api.alphashop.cn/ai.*` REST | `FAIL_SERVER_INTERNAL_ERROR`（后端整体故障）|

## 已验证不是问题的方面

| 项目 | 结论 |
|------|------|
| DNS 解析 | ✅ 正常，指向阿里云 Tengine |
| HTTP 连接 | ✅ TCP 建立成功，HTTP 200 |
| JWT 格式 | ✅ 包含 `iat` + `jti` + `nbf`，格式正确 |
| Token 有效期 | ✅ 每次请求动态生成（TTL=1800s） |
| Accept header | ✅ 发送了 `Accept: text/event-stream` |
| 多路复用 | ✅ 已合并为单通道（6合1 bridge） |

## 用户提供的关键文档结论（MCP服务.md）

1. **SSE 必须带 header**: `Accept: text/event-stream`，部分实现默认不发送导致握手被截断
2. **JWT 载荷必须包含**: `iat: int(time.time())` + `jti: str(uuid.uuid4())`
3. **必须在连接后 100ms 内发送 MCP `initialize`** 调用
4. **不能用标准 REST 客户端**，必须用支持 SSE 协议栈的 MCP SDK
5. **Token 30分钟过期**：静态 Token 会导致服务端静默拦截（返回 0 bytes）

## OpenClaw 用户可以正常使用

说明 Alphashop MCP 服务端本身是正常的，可能是：
- 不同 MCP client 实现的传输层差异（Hermes 的 SSE 实现 vs OpenClaw 的）
- 不同的连接策略（重试间隔、ping/pong 心跳、buffer 配置）

## 调试命令

```bash
# 动态生成 JWT 并测试 SSE
TOKEN=$(node -e "const auth=require('$(npm root -g)/1688alphaclaw/lib/auth.js'); console.log(auth.generateAuthHeader('ACCESS_KEY','SECRET_KEY',1800))")
python3 -c "
import urllib.request, urllib.parse
req = urllib.request.Request(f'https://mcp.alphashop.cn/sse?key={urllib.parse.quote(\"$TOKEN\")}')
req.add_header('Accept', 'text/event-stream')
req.add_header('User-Agent', 'MCP-Client/1.0.0')
with urllib.request.urlopen(req, timeout=5) as r:
    print('Status:', r.status, 'Content-Length:', r.headers.get('Content-Length'))
    print('Body:', r.read(100))
"

# 测试 REST API
curl -s -X POST "https://api.alphashop.cn/ai.keyword.search/1.0" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"test"}'
```

## 结论

服务端持续返回 HTTP 200 + Content-Length: 0，非客户端问题。建议：
1. 联系 Alphashop/遨虾技术支持
2. 确认账户积分余额（部分服务需要余额充足才推送数据）
3. 等官方修复或确认是否有账号级别的接入白名单
