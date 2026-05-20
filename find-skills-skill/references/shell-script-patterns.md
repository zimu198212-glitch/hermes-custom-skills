# Shell Script Patterns (session-validated pitfalls)

## skills.sh — grep filter

```bash
# ❌ WRONG: captures "Install with npx..." banner line
result=$(npx --yes skills find "$QUERY" 2>/dev/null | grep "@" | head -20)

# ✅ CORRECT: exclude banner
result=$(npx --yes skills find "$QUERY" 2>/dev/null | grep "@" | grep -v "Install with" | head -20)
```

## ClawHub — PATH must include /data/node-global/bin

```bash
# ❌ WRONG: "clawhub: command not found"
export PATH="/usr/local/bin:/usr/bin:$PATH"

# ✅ CORRECT: include node-global
export PATH="/data/node-global/bin:$PATH:$HOME/.local/bin:$PATH"
```

Check: `find /data/node-global /home/ubuntu/.local -name "clawhub" 2>/dev/null`

## skillhub.cn — keyword filter must be specific

```bash
# ❌ WRONG: matches summarize, github, web-tools etc.
result=$(skillhub search "$QUERY" 2>&1 | grep -E "^\S" | head -20)

# ✅ CORRECT: strict keyword match + exclude noise
result=$(skillhub search "$QUERY" 2>&1 | grep -E "ozon|wildberries|1688.*ozon|mpstats|clawec" \
  | grep -vE "You can|version:|Summarize|Github|humanizer|web-tools|skill-creator|ima-skills|baozong|A股|港股|美股" | head -20)
```

## SkillsMP — .env sourcing required

```bash
# ❌ WRONG: $api_key is empty, SkillsMP returns 0 silently
curl -s "...?q=$QUERY&limit=10" -H "Authorization: Bearer $SKILLSMP_API_KEY"

# ✅ CORRECT: source .env first
[ -f "$HOME/.env" ] && source "$HOME/.env" 2>/dev/null
```

## Local Hermes — avoid find -print0 + read -d '' pitfall

```bash
# ❌ BROKEN: some files silently dropped in while-read loop
while IFS= read -r -d '' SKILL; do
  DIR=$(basename "$(dirname "$SKILL")")
  echo "$DIR"
done < <(find /home/ubuntu/.hermes/skills -name "SKILL.md" -print0 2>/dev/null)

# ✅ CORRECT: simple for loop (no subshell, no -print0 issues)
for SKILL in $(find /home/ubuntu/.hermes/skills -name "SKILL.md" 2>/dev/null); do
  if grep -iq "$QUERY" "$SKILL" 2>/dev/null; then
    DIR=$(basename "$(dirname "$SKILL")")
    echo "$DIR"
  fi
done
```

## agentskill.sh — strip ANSI before parsing

```bash
# ❌ WRONG: ANSI escape codes pollute output
result=$(ags search "$QUERY" 2>/dev/null | grep "Quality:" | head -20)

# ✅ CORRECT: clean ANSI first
clean=$(echo "$raw" | sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\r//g')
result=$(echo "$clean" | grep -E "Quality:|quality" | head -20)
```

## GitHub — use gh search repos, NOT gh search code

```bash
# ❌ WRONG: gh search code always returns 0 for SKILL.md
gh search code "filename:SKILL.md ozon" --limit 20 --language markdown

# ❌ WRONG: web search "site:github.com SKILL.md ozon" also returns 0
# Search engines don't index small skill repos

# ✅ CORRECT: gh search repos first, then verify SKILL.md exists
for repo in $(gh search repos "skill-ozon" --limit 10 --json nameWithOwner --jq '.[].nameWithOwner'); do
  if gh api repos/$repo/contents/SKILL.md --jq '.name' 2>/dev/null | grep -q SKILL.md; then
    echo "✅ $repo has SKILL.md"
  fi
done
```

## SkillsMP — query enrichment rule

Short marketplace keywords get mapped to wrong semantic categories (e.g. "OZON" → chemical element, 0.001 score).

```bash
# ❌ WRONG: OZON alone → 0 results or wrong category
curl "...?q=OZON&limit=10"

# ✅ CORRECT: always append domain context
curl "...?q=OZON+ecommerce&limit=10"
curl "...?q=OZON+seller+Russia&limit=10"
```