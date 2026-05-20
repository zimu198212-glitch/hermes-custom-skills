# hermes-custom-skills

Custom Hermes Agent skills, managed as a monorepo.

## Skills

| Skill | Description |
|-------|-------------|
| `agent-security-hardening` | Security patterns for production AI agents |
| `agent-skills-auto-updater` | Auto-update skills via git (self-update capable) |
| `cross-border-ecommerce-skill` | Cross-border expansion advisor (OZON-focused) |
| `find-skills-skill` | Multi-source skill search aggregator |
| `yuanbao` | Tencent Yuanbao group interaction |

## Updating

This repo is mirrored from `~/.hermes/skills/hermes-custom-skills/`.
Git push is restricted on the server; updates are made via GitHub Contents API.

## Sync Instructions

When you modify a skill locally:
1. Push changes via GitHub API (or manually on GitHub web)
2. On server: `cd ~/.hermes/skills/hermes-custom-skills && git pull`

The `agent-skills-auto-updater` cron job (ID: a74fa000b21e) handles auto-sync daily at 3 AM.
