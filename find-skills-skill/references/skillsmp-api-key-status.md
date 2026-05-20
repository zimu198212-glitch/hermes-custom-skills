# SKILLSMP API Key 配置状态

## 当前状态
- **状态**: ❌ 未配置（key 已知但未写入 .env）
- **Key**: `sk_live_skillsmp_lU2TJY2wtIpf6EwOdgzks0ipTLDKiZGErCwJDM8xs3g`
- **需要写入**: `~/.hermes/.env` → `SKILLSMP_API_KEY=sk_live_skillsmp_lU2TJY2wtIpf6EwOdgzks0ipTLDKiZGErCwJDM8xs3g`

## 验证命令（配置完成后）
```bash
curl -s "https://skillsmp.com/api/v1/skills/ai-search?q=ozon&limit=3" \
  -H "Authorization: Bearer $SKILLSMP_API_KEY" | python3 -c "import sys,json; d=json.load(sys.stdin); [print(s['skill']['name']) for s in d['data']]"
```

## find-skills-skill 的 required_environment_variables
目前 skill metadata 缺少 `SKILLSMP_API_KEY` 在 `required_environment_variables` 列表中，导致 skill 被标记为"已就绪"但实际无法正常工作。

修复方法：在 skill 的 SKILL.md frontmatter 中添加或确认：
```yaml
required_environment_variables:
  - SKILLSMP_API_KEY
```