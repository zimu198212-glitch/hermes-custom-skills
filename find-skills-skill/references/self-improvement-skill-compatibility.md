# Self-Improvement/Proactive/Metacognition Skill Compatibility Report

**Generated:** 2026-05-19
**Scope:** 16 deduplicated skills across ClawHub, agentskill.sh, SkillsMP, skillhub.cn

---

## Summary Table

| # | Name | Source | Quality/Security | Hermes Compatible | Notes |
|---|------|--------|-----------------|-----------------|-------|
| 1 | `metacognition` (meimakes) | ClawHub | CLEAN | ✅ Available | Hebbian加权图自反思引擎，Python依赖 |
| 2 | `proactive-agent` (GeorgeDoors888) | agentskill.sh | 100/100 | ⚠️ Cannot verify | agentskill.sh API "no available server"，作者GitHub无此repo |
| 3 | `self-healing-agents` | SkillsMP | — | ⚠️ Cannot verify | SkillsMP页面404，API 404 |
| 4 | `self-improving-proactive-agent` (yueyanc) | ClawHub | CLEAN | ❌ | metadata明确clawdbot，heartbeat机制 |
| 5 | `self-improving` (ivangdavila) | skillhub.cn | CLEAN | ❌ | OpenClaw专用，heartbeat md文件 |
| 6 | `proactive-agent` (halthelobster) | Both | ❌ SUSPICIOUS | ❌ | 安全警告 |
| 7 | `proactive-agent-lite` | ClawHub | ⚠️ SUSPICIOUS | ❌ | 安全警告 |
| 8 | `metacognition-lite` | skillhub.cn | ⚠️ SUSPICIOUS | ❌ | 安全警告 |
| 9 | `proactive-memory-agent` | ClawHub | ⚠️ SUSPICIOUS | ❌ | shell脚本依赖 |
| 10 | `16-self-improving...` (smallkeyboy) | ClawHub | CLEAN | ❌ | metadata: clawdbot |
| 11 | `metacognitive-self-mod` | agentskill.sh | 97/100 | ⚠️ Cannot verify | 页面404 |
| 12 | `oc-metacognition` | agentskill.sh | 98/100 | ⚠️ Cannot verify | 页面404 |
| 13 | `adaptive-mind` | SkillsMP | — | ⚠️ Cannot verify | 页面404 |
| 14 | `self-improving-agent-cn` | ClawHub | ⚠️ SUSPICIOUS | ❌ | 安全警告 |
| 15 | `self-improving-learner` | Both | — | ⚠️ Cannot verify | 未查 |
| 16 | `self-improving-agent` (pskoett) | Both | CLEAN | ⚠️ Partial | 核心SKILL.md无依赖，hooks可选 |

---

## Key Findings

### ✅ Available for Installation

**`metacognition` (meimakes) — Recommended**
- Hebbian加权图自反思引擎（perceptions/overrides/protections/self-observations/decisions/curiosities）
- 时间衰减 + token budget lens编译
- Python3 stdlib only（无外部包依赖）
- MIT-0 license
- 文件：SKILL.md + 32KB `metacognition.py`
- 安装路径：`/data/hermes-webui/skills/metacognition`

**`self-improving-agent` (pskoett) — Partial可用**
- 核心SKILL.md无依赖，`.learnings/`文件日志
- hooks可选（Node.js），无hook也能用
- 安装路径：`~/.hermes/skills/` 或 `~/.openclaw/skills/`

### ❌ Not Compatible with Hermes

| Skill | Reason |
|-------|--------|
| `self-improving` (ivangdavila) | 依赖`openclaw-heartbeat.md`，`~/self-improving/`固定目录 |
| `self-improving-proactive-agent` | heartbeat-rules.md等OpenClaw机制 |
| `16-self-improving...` | metadata明确`clawdbot` |
| `proactive-agent` (halthelobster) v3.1.0 | SUSPICIOUS安全警告 |
| `proactive-agent-lite` | SUSPICIOUS安全警告 |
| `proactive-memory-agent` | shell脚本依赖 |
| `self-improving-agent-cn` | SUSPICIOUS安全警告 |

### ⚠️ Cannot Verify (Orphaned Skills)

**Confirmed orphaned pattern:**
- SkillsMP/agentskill.sh 搜索返回结果 ✅
- 但实际页面/API 404 ❌
- 作者GitHub无此repo ❌
- 原因：已下架但搜索索引未更新

**Orphaned skills (cannot be installed):**
- `proactive-agent` (GeorgeDoors888) — agentskill.sh API "no available server"
- `self-healing-agents` — SkillsMP页面404
- `metacognitive-self-mod` — agentskill.sh页面404
- `oc-metacognition` — agentskill.sh页面404
- `adaptive-mind` — SkillsMP页面404

### 🔑 Hermes-Only Viable Option

**`hermes-agent` (ivangdavila)** — 唯一专门为Hermes设计的skill
- 来自ClawHub，已安装到 `~/.hermes/skills/hermes-agent/`
- MIT-0, CLEAN安全
- 支持SOUL.md/AGENTS.md/HEARTBEAT.md

---

## Installation Status

| Skill | Status |
|-------|--------|
| `metacognition` | ✅ Installed to `/data/hermes-webui/skills/metacognition` |
| `hermes-agent` | ✅ Installed to `~/.hermes/skills/hermes-agent/` |
| All others | ❌ Not installed |

---

## Lessons Learned

1. **SkillsMP/agentskill.sh results ≠ installable** — Always verify page exists before recommending
2. **"Hermes可用"需要检查**: 纯SKILL.md > 有hooks > 有Python/Node依赖 > OpenClaw专用
3. **agentskill.sh "no available server"** = 服务端实际已下线/不可用
4. **Same skill on multiple sources** = one skill, list all sources, pick best available path
