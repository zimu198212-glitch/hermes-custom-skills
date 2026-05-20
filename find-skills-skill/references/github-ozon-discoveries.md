# GitHub OZON Skill Discoveries (Session-Validated)

## Confirmed GitHub Repos with OZON Skills

### smvlx/openclaw-ru-skills ⭐
https://github.com/smvlx/openclaw-ru-skills

**marketplace-ru** skill — Ozon / Wildberries / Яндекс Маркет 订单/价格/库存管理
- Platforms: OpenClaw, Claude Code, Any AI Agent
- Features: Seller API v3/v4, FBS/FBO, multi-warehouse stock
- CLI tools: `mp-setup`, `mp-test`, `mp-orders`, `mp-prices`, `mp-stocks`
- Requires: `jq`, `curl`, bash 3.2+
- Install: clone repo, copy `skills/marketplace-ru/` to your skill dir

```bash
git clone https://github.com/smvlx/openclaw-ru-skills.git
# then copy skills/marketplace-ru/ to your agent's skills dir
```

### VoltAgent/awesome-openclaw-skills
https://github.com/VoltAgent/awesome-openclaw-skills
- 5,400+ OpenClaw skills curated from ClawHub
- 48.7k stars, 4.8k forks
- Search for OZON/WILDBERRIES within this repo's README

## Search Patterns That Actually Work

### gh CLI (no SKILL.md format repos exist)
```bash
gh search repos "ozon in:name" --limit 10   # finds apache/ozone, gam6itko/ozon-seller etc (wrong ozon)
gh search code "filename:SKILL.md ozon" --limit 10  # returns nothing
gh search repos "openclaw skill" --limit 5   # finds awesome lists but no OZON
```

### web_search (what actually finds SKILL.md files)
```python
# Best pattern — find skills by repo author who publishes SKILL.md
web_search(limit=10, query='site:github.com "SKILL.md" hermes-agent OZON ecommerce skill')
web_search(limit=10, query='site:github.com "SKILL.md" openclaw-skills OZON')

# Also valid: search known skill authors
web_search(limit=10, query='site:github.com/AgentWorkers/skills OZON')
web_search(limit=10, query='site:github.com/Bobr2610 ozon-shopper')

# Extract skill URLs from SkillsMP results
# SkillsMP returns author/repo URLs in skill.author field
# Check if those GitHub repos actually exist and contain SKILL.md
```

## What Was NOT Found
- No hermes-agent-specific OZON SKILL.md repos on GitHub
- SkillsMP-referenced GitHub URLs (AgentWorkers/skills, Bobr2610/ozon-shopper_skill) are dead/inaccessible
- gh CLI `search code filename:SKILL.md` returns zero results for OZON