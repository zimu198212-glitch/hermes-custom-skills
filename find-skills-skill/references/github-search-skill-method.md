# GitHub Skill Search — Correct Method (Session-validated)

## The Problem

`web_search site:github.com "SKILL.md" <query>` and `gh search code filename:SKILL.md <query>` both return **0 results** for actual skill repos. GitHub's search engine does not reliably index small/private SKILL.md files.

## The Correct Method

**Step 1 — Find candidate repos with `gh search repos`:**

```bash
gh search repos "skill-ozon" --limit 10
gh search repos "ozon stock manager" --limit 10
gh search repos "1688-product-to-ozon" --limit 10
gh search repos "marketplace-ru ozon" --limit 10
gh search repos "openclaw ozon" --limit 10
gh search repos "alphaclaw ozon" --limit 10
```

Use **keyword combinations**, not single terms. `skill-ozon` works; `ozon` alone returns SDK repos.

**Step 2 — Verify each repo has a SKILL.md:**

```bash
gh api repos/<owner>/<repo>/contents/SKILL.md --jq '.content' 2>/dev/null | base64 -d | head -3
```

If this returns 404, the repo is a code library (SDK), not a skill. Skip it.

**Step 3 — Extract name + description:**

```bash
gh api repos/<owner>/<repo>/contents/SKILL.md --jq '.content' | base64 -d | grep -E "^name:|^description:" | head -2
```

## Why Old Methods Failed

| Method | Result | Why |
|--------|--------|-----|
| `web_search "site:github.com SKILL.md ozon"` | 0 relevant results | GitHub search doesn't index small SKILL.md files |
| `gh search code filename:SKILL.md ozon` | 0 results | Same — code search is for file content, not filename indexed |
| `gh search repos "ozon skill"` | SDK repos mixed in | Single keywords return API client libraries, not skills |

## Verified OZON Skills Found This Way (2026-05-16)

| Repo | Skill | Has SKILL.md |
|------|-------|-------------|
| smvlx/openclaw-ru-skills | marketplace-ru | ✅ |
| jinguichen21-cloud/ozon-stock-manager | ozon-stock-manager | ✅ |
| jinguichen21-cloud/skill-ozon-product-selection | ozon-product-selection | ✅ |
| jinguichen21-cloud/1688-product-to-ozon | 1688-product-to-ozon | ✅ |
| jinguichen21-cloud/skill-1688-product-to-ozon | 1688-Product-to-Ozon | ✅ |
| ozonleo/1688-product-to-ozon | 1688-Product-to-Ozon | ✅ |
| Bobr2610/ozon-shopper_skill | ozon-shopper | ✅ |

## Installation from GitHub

```bash
# Clone and extract SKILL.md
gh repo clone <owner>/<repo> /tmp/<repo-name>
# Or download just the SKILL.md
gh api repos/<owner>/<repo>/contents/SKILL.md --jq '.content' | base64 -d > /tmp/<repo-name>/SKILL.md

# Install to local Hermes skills
mkdir -p ~/.hermes/skills/skills/<skill-name>
# Copy the skill files
```

Note: GitHub repos often have non-standard layouts. The SKILL.md may be in `skills/<skill-name>/SKILL.md` rather than root.
