# agentmemory Skill Search — 2026-05-19

## Search Results

| Name | Source | Rating/Score | Security | Status |
|------|--------|-------------|----------|--------|
| agentmemory | ClawHub | 4.25/5 ⭐ | Warn (agentic behavior review) | ✅ |
| agentmemory | agentskill.sh | 67/100 | — | ✅ |
| agentMemory | agentskill.sh | 58/100 | — | ✅ |
| AgentMemory Skill | agentskill.sh | 0/100 | — | ✅ |
| recall | agentskill.sh | 75/100 | — | ✅ |
| agentmemory-mcp | ClawHub | 2.96/5 | — | ✅ |

**ClawHub URL:** `https://clawhub.ai/badaramoni/agentmemory`

**Install:**
```bash
openclaw skills install agentmemory
```

## Security Note

ClawHub page shows `⚠️ Warn` — "Agentic behavior and permission review". Not automatically installed.

## gemini-custom Provider in Hermes

**API endpoint:** `http://localhost:8787/api/providers`
```json
{
  "id": "custom:gemini-custom",
  "models": [
    {"id": "google/gemini-3.1-flash-lite-preview", "label": "google/gemini-3.1-flash-lite-preview"},
    {"id": "google/gemini-3.1-flash-image-preview", "label": "google/gemini-3.1-flash-image-preview"}
  ]
}
```

**Key model name insight:** When calling the CF proxy directly, the model name MUST use full `google/gemini-3.1-flash-lite-preview` format. Using `gemini-custom` as model name causes 404 "models/gemini-custom is not found".

**Hermes provider plugin registered at:** `/home/ubuntu/.hermes/plugins/model-providers/gemini-custom/`
