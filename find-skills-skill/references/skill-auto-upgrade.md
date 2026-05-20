# Skill Auto-Upgrade Search Results (2026-05-20)

## Key Finding: No Hermes-Native Auto-Upgrade Skill Exists

All auto-upgrade skills found are **OpenClaw-specific** — they depend on OpenClaw's skill management architecture (`OPENCLAW_SKILLS_DIR`, `clawhub update`, etc.).

## Verified Incompatible (OpenClaw-Only)

| Skill | Source | Why Incompatible |
|-------|--------|-----------------|
| `skill-auto-updater` | ClawHub (tempest-01) | Requires `clawhub update` + `OPENCLAW_SKILLS_DIR` env |
| `skills-updater` | ClawHub (thunder1743) | Same — OpenClaw clawhub update mechanism |
| `openclaw-auto-updater` | skills.sh (896 installs) | OpenClaw专用 |
| `auto-updater` series (many) | ClawHub | All依赖OpenClaw机制 |

## Closest Compatible: agent-skills-auto-updater

- **Repo**: github.com/Lucker-QY/agent-skills-auto-updater
- **Install**: `gh api repos/Lucker-QY/agent-skills-auto-updater/contents/scripts/agent_skills_auto_updater.py --jq '.content' | base64 -d > /tmp/agent_skills_auto_updater.py`
- **Key advantage**: Supports `--root` flag to point at arbitrary skill directories
- **Hermes usage**: `python3 agent_skills_auto_updater.py --root ~/.hermes/skills --check`
- **Limitation**: Designed for Git-backed skills; Hermes skills may not all be Git-managed
- **CLI options**: `--check` (status only), `--apply` (safe fast-forward), `--json`, `--list-roots`

## Hermès Skill Update Workflow (Current)

Since no auto-upgrade skill exists, manual workflow:
1. `hermes skills list` — 查看已安装skill
2. `hermes skills update <name>` — 升级单个skill
3. Or: delete and re-install from source

## Search Queries That Work for Auto-Upgrade

```bash
# Skills.sh
bash scripts/search-all.sh "auto upgrade skill"

# ClawHub
/data/node-global/bin/clawhub inspect <slug>

# GitHub (via agent-skills-auto-updater search)
gh search repos "skill auto updater" --limit 10
gh search repos "agent skills auto updater" --limit 5
```
