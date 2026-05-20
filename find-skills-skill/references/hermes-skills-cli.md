# Hermes Skills CLI (hermes skills)

## What It Is

`hermes skills` is the **official built-in marketplace CLI** for Hermes Agent. Located at `~/.hermes/hermes-agent/venv/bin/hermes skills`. It is NOT part of `find-skills-skill`'s `search-all.sh` — it must be called separately.

## Key Commands

```bash
HERMES_BIN="$HOME/.hermes/hermes-agent/venv/bin/hermes"

# Search across all sources
$HERMES_BIN skills search "query"

# Browse a specific source (paginated)
$HERMES_BIN skills browse --source <source> --page <N>
# Sources: official, skills-sh, well-known, github, clawhub, lobehub

# Install (interactive — must pipe 'y')
echo "y" | $HERMES_BIN skills install <identifier>

# List configured taps
$HERMES_BIN skills tap list

# Add a GitHub repo as a skill source
$HERMES_BIN skills tap add <owner/repo>

# Inspect without installing
$HERMES_BIN skills inspect <identifier>
```

## Hermes Skills vs find-skills-skill

| Task | Tool |
|------|------|
| Search installed skills | `hermes skills list` |
| Search available skills | `hermes skills search <query>` |
| Browse marketplace by source | `hermes skills browse --source clawhub --page N` |
| Multi-source aggregated search | `find-skills-skill/scripts/search-all.sh` |

**Rule:** Use both. `hermes skills search` finds from official registries. `find-skills-skill` aggregates 9 sources including agentskill.sh, SkillsMP, 168alphaclaw, local.

## Known Taps (2026-05-19)

- `prompt-security/clawsec` — security hardening suite for Hermes/OpenClaw
- `OthmanAdi/planning-with-files` — planning workflow

## Hermes Market Sources (6 built-in)

- **official** — NousResearch bundled skills (689 skills)
- **skills-sh** — skills.sh registry
- **well-known** — known endpoints
- **github** — GitHub repos
- **clawhub** — clawhub.com registry (280 skills as of 2026-05)
- **lobehub** — lobehub.com registry

## ClawHub Browse Results (280 skills, 14 pages)

When browsing ClawHub, use `--page 1` through `--page 14`. Each page shows ~20 skills. Use `grep -iE "self|meta|proactive|harden|evolv|memory|reflect"` to filter for self-improvement/proactive skills.

## Unicode Box Characters

`hermes skills` output uses Unicode box-drawing chars:
- `│` (U+2502) instead of ASCII `|`
- `┡` (U+2521) for dividers
- `━` (U+2501) for horizontal lines

Standard `grep "|"` patterns **will not match**. Use:
```bash
echo "$result" | grep "^│" | grep -v "^┡" | grep -v "^│ Name"
```
