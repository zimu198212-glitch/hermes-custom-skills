# SkillsMP API Key Setup

## Get Key
1. Visit https://skillsmp.com → Dashboard → API Key
2. Format: `sk_live_skillsmp_lU2TJY2wtIpf6EwOdgzks0ipTLDKiZGErCwJDM8xs3g`

## Store
```bash
echo "SKILLSMP_API_KEY=sk_live_skillsmp_lU2TJY2wtIpf6EwOdgzks0ipTLDKiZGErCwJDM8xs3g" >> ~/.env
```

## Use in scripts
```bash
[ -f "$HOME/.env" ] && source "$HOME/.env" 2>/dev/null
api_key="${SKILLSMP_API_KEY:-}"
curl -s "https://skillsmp.com/api/v1/skills/ai-search?q=$QUERY&limit=10" \
  -H "Authorization: Bearer $api_key"
```

## Response Shape
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "score": 0.536,
        "skill": {
          "name": "ozon-product-selection",
          "author": "AgentWorkers",
          "description": "...",
          "skillUrl": "https://skillsmp.com/skills/..."
        }
      }
    ]
  }
}
```
Note: `data.data[].skill` — nested, NOT `data.skills[]`

## OZON Query Patterns
| Query | Results | Notes |
|-------|---------|-------|
| `OZON` | 1 (chemistry) | Too generic |
| `OZON ecommerce` | 6 | Good |
| `OZON Russia seller` | 6 | Good |
| `OZON+wildberries` | 5 | Cross-platform |

**Always enrich short keywords** — semantic search maps "OZON" to chemical element.