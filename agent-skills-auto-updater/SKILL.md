---
name: agent-skills-auto-updater
description: Check, prompt for, and safely update all locally installed Git-backed AI agent skills across Codex and other skill roots. Use when the user asks to update local skills, sync skills with GitHub, check whether installed skills are outdated, audit local skill versions, or create/run an automation that keeps local agent skills current.
---

# Agent Skills Auto Updater

## Workflow

1. Locate this skill folder and run the bundled updater:

```bash
python3 ~/.hermes/skills/agent-skills-auto-updater/scripts/agent_skills_auto_updater.py --apply
```

2. If the user only asks for a status check, use:

```bash
python3 ~/.hermes/skills/agent-skills-auto-updater/scripts/agent_skills_auto_updater.py --check
```

3. Report the summary table: updated, already current, skipped, and failed repositories.

## Hermes-Specific Usage

For Hermes skills, use `--root ~/.hermes/skills`:

```bash
# Check for updates in Hermes skills
python3 ~/.hermes/skills/agent-skills-auto-updater/scripts/agent_skills_auto_updater.py --check --root ~/.hermes/skills

# Apply updates to Hermes skills
python3 ~/.hermes/skills/agent-skills-auto-updater/scripts/agent_skills_auto_updater.py --apply --root ~/.hermes/skills
```

## Options

- Add `--root <path>` to scan a specific skills directory (e.g. `~/.hermes/skills`).
- Add `--list-roots` to show which roots would be scanned.
- Add `--json` when machine-readable output is useful.
- Add `--include-system` to include `.system` skills.
