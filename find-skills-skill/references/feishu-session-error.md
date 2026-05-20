# Feishu/Hermes Chat Session Error Analysis

**Generated:** 2026-05-19 04:xx
**Session:** feishu 会话错误排查

---

## 错误现象

飞书发消息后 Hermes 无响应，日志显示：
```
Transient agent failure in session 20260519_034541_e88b34
```
所有飞书消息（"测试"、"重启"、"反馈"）均失败。

---

## 根因

```
provider=gemini-custom base_url=https://dangyidang.qzz.io/v1
model=google/gemini-3.1-flash-lite-preview
summary=HTTP 403: Your request was blocked.
```

**飞书会话走的是 `gemini-custom` provider（dangyidang 代理），该代理返回 403 "Your request was blocked" — 不是 token 配额问题，是模型后端拒绝服务。**

---

## 对比：WebUI vs 飞书

| 渠道 | Provider | 状态 |
|------|----------|------|
| WebUI 当前会话 | `minimax-cn` (m2.7) | ✅ 正常 |
| 飞书会话 | `gemini-custom` (dangyidang) | ❌ 403 blocked |

---

## 排查步骤

```bash
# 1. 查看 gateway 日志中的 agent failure
tail -200 ~/.hermes/logs/gateway.log | grep "Transient agent failure"

# 2. 查看具体错误原因
tail -200 ~/.hermes/logs/agent.log | grep "PermissionDenied\|403\|blocked"

# 3. 查看飞书 channel 的 provider 配置
grep -r "gemini-custom\|dangyidang" ~/.hermes/config.yaml 2>/dev/null
```

---

## 修复方向

飞书 channel 的 agent 配置需要切换到可用的 provider（如 `minimax-cn`）。

**注意：** 这是 provider 层面的 403，不是 skill 或 MCP 问题。
