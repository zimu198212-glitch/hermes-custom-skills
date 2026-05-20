# GitHub SKILL.md Search — OZON 验证结果

## 实测结论

GitHub 上不存在格式规范的 OZON/俄罗斯电商 SKILL.md skill 文件。

| 查询 | 结果 |
|------|------|
| `site:github.com OZON SKILL.md` | 0 |
| `site:github.com ozon-shopper` | 0 |
| `site:github.com AgentWorkers skills` | 0 |
| `gh search repos "ozon skill SKILL.md"` | 0 |
| `gh search code "filename:SKILL.md ozon"` | 0 |

SkillsMP 中引用的 GitHub URL（如 `AgentWorkers/skills`、`Bobr2610/ozon-shopper_skill`）：
- repo 不存在，或 SKILL.md 未被搜索引擎索引
- SkillsMP 的语义搜索匹配到的是 semantic 相关性（非格式有效性）

## 对 find-skills 架构的影响

Shell 脚本 `search-all.sh` 的 `search_github()` 函数**只能打印占位符**（无法调用 `web_search`）。Agent 看到输出后，必须自行补一次 `web_search` 调用才算完成 GitHub 搜索。

**关键区别：**
- skills.sh / ClawHub / agentskill.sh / skillhub.cn → shell 脚本直接返回结果
- GitHub / SkillsMP → shell 脚本打印占位符，**Agent 必须调用工具补全**

## Agent 应执行的 GitHub 搜索模式

```python
web_search(f"site:github.com SKILL.md {query}")
web_search(f"site:github.com hermes-agent skill {query}")
# 无需额外搜索（gh CLI auth 复杂，web_search 已足够）
```

**验证发现：** 即使执行了上述查询，OZON 关键词仍返回 0 结果 — GitHub 对 OZON 这个类目不是一个有效来源。

## 实践建议

对 OZON 俄罗斯电商类 skill 搜索：
- GitHub 步骤可**跳过**（已验证返回 0）
- 优先搜索顺序：**SkillsMP > ClawHub > skills.sh > agentskill.sh > Local Hermes**
- 如果所有源都返回 0，建议直接调用 1688/OZON API 工具而非继续搜 skill