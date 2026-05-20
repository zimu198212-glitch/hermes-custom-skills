# GitHub SKILL.md Search — Verified Patterns

## Core Lesson

**`gh search code filename:SKILL.md <query>` → 0 results (always)**
**`gh search repos <keyword-combinations>` → finds repos, then verify SKILL.md separately**

gh search code 只搜代码内容，不搜 repo 元数据。GitHub 搜索引擎不索引小众/新创建 repo 的文件名。必须用 gh search repos + API 验证。

## Verified Search Queries (OZON as test case)

### ✅ Returns results
```bash
gh search repos "skill-ozon" --limit 10
gh search repos "ozon stock manager" --limit 10
gh search repos "ozon-product-selection" --limit 10
gh search repos "1688-product-to-ozon" --limit 10
gh search repos "marketplace-ru ozon" --limit 10
```

### ❌ Returns 0
```bash
gh search code "filename:SKILL.md ozon" --language markdown
gh search code "path:skills ozon" --language markdown
site:github.com "SKILL.md" OZON
site:github.com hermes-agent OZON skill SKILL.md
```

## SKILL.md Verification Workflow

For each repo found by `gh search repos`, verify SKILL.md exists:
```bash
gh api repos/<owner>/<repo>/contents/SKILL.md --jq '.content' | base64 -d | head -5
```
If returns empty/not found → skip (it's an SDK, not a skill).

## Why: Many OZON repos are SDKs

GitHub 上 OZON 相关 repo 分两类：
- **SKILL 文件** — 有 SKILL.md，AI agent skill
- **SDK 代码库** — ozon-seller PHP、ozon-api-client Go、ozon-daytona TypeScript — 不是 skill

Only repos with SKILL.md in root are actual skills.

## Known OZON Skill Repos (2026-05 verified)

| Repo | Skill | Platform |
|------|-------|----------|
| jinguichen21-cloud/ozon-stock-manager | ozon-stock-manager | hermes/openclaw |
| jinguichen21-cloud/skill-ozon-product-selection | ozon-product-selection | hermes/openclaw |
| jinguichen21-cloud/1688-product-to-ozon | 1688-product-to-ozon | hermes/openclaw |
| coral870921-source/Ozon-Profit-Skills | ozon-listing etc. | Claude Code |
| esporykhin/claude-code-skills | ozon-seller-api | hermes/openclaw | ✅ |
| smvlx/openclaw-ru-skills/marketplace-ru | marketplace-ru | OpenClaw | ✅ |
| Bobr2610/ozon-shopper_skill | ozon-shopper | OpenClaw |