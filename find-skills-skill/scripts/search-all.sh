#!/usr/bin/env bash
# ============================================================
# Unified Skills Search - aggregates results from 10 sources:
#   1. skills.sh     (npx skills find)
#   2. ClawHub       (clawhub search)
#   3. GitHub        (agent web_search — script placeholder)
#   4. agentskill.sh (ags search)
#   5. skillhub.cn   (skillhub search)
#   6. SkillsMP      (curl API)
#   7. 168alphaclaw  (alphaclaw search — Alibaba SkillHub)
#   8. Local Hermes  (grep in ~/.hermes/skills/ — 2 depth levels)
#
# Usage: ./search-all.sh <query>
# ============================================================
export PATH="/data/node-global/bin:$PATH:/home/ubuntu/.local/bin:$PATH"
# Load .env files for API keys
for env_file in "$HOME/.hermes/.env" "$HOME/.env" "/data/.env"; do
  [ -f "$env_file" ] && source "$env_file" 2>/dev/null
done

QUERY="${1:-}"
[ -z "$QUERY" ] && echo "Usage: $0 <query>" && exit 1

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; RESET='\033[0m'

TMP=$(mktemp)
cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

# --- 1. skills.sh ---
search_skills_sh() {
  echo "=== SKILLS.SH ==="
  if command -v npx &>/dev/null; then
    result=$(npx --yes skills find "$QUERY" 2>/dev/null | sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g' | grep -E '@|https://' | head -20)
    [ -n "$result" ] && echo "$result" || echo "  (no results)"
  else
    echo "  (npx not found)"
  fi
}

# --- 2. ClawHub ---
search_clawhub() {
  echo "=== CLAWHUB ==="
  if command -v clawhub &>/dev/null; then
    result=$(clawhub search "$QUERY" 2>/dev/null | grep -E '\S' | head -30)
    [ -n "$result" ] && echo "$result" || echo "  (no results)"
  else
    echo "  (clawhub not found)"
  fi
}

# --- 3. GitHub (gh CLI — authenticated) ---
search_github() {
  echo "=== GITHUB ==="
  if ! command -v gh &>/dev/null; then
    echo "  (gh CLI not found)"
    return
  fi
  # Search repos with hermes-skill or SKILL.md topic
  result=$(timeout 12 gh search repos "$QUERY" --limit 5 --json name,description,url 2>/dev/null)
  if [ -n "$result" ] && [ "$result" != "[]" ]; then
    echo "$result" | python3 -c "
import sys,json
data=json.load(sys.stdin)
for r in data:
    print(f\"  {r['name']} — {r.get('description','')[:70]}\")
    print(f\"    {r['url']}\")
" 2>/dev/null || echo "  (gh auth required: gh auth login)"
  else
    echo "  (no results)"
  fi
}

# --- 4. agentskill.sh ---
search_ags() {
  echo "=== AGENTSKILL.SH ==="
  if command -v ags &>/dev/null; then
    raw=$(ags search "$QUERY" 2>/dev/null)
    # Strip all ANSI escape sequences
    clean=$(echo "$raw" | sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g; s/\x1b\?25[lh]//g; s/\r//g')
    # Extract skill lines that match the query keyword
    result=$(echo "$clean" | grep -i "$QUERY" | grep -vE 'Searching|Found|Install|Skip|Author|Quality|Security|^\s*[│●○]|^\s*$' | head -20)
    [ -n "$result" ] && echo "$result" || echo "  (no results)"
  else
    echo "  (ags not found)"
  fi
}

# --- 5. skillhub.cn ---
search_skillhub() {
  echo "=== SKILLHUB.CN ==="
  if command -v skillhub &>/dev/null; then
    result=$(skillhub search "$QUERY" 2>/dev/null | grep -E '\S' | head -30)
    [ -n "$result" ] && echo "$result" || echo "  (no results)"
  else
    echo "  (skillhub not found)"
  fi
}

# --- 6. SkillsMP (AI semantic search) ---
search_skillsmp() {
  echo "=== SKILLSMP ==="
  # API key must be set in environment or .env
  local api_key="${SKILLSMP_API_KEY:-}"
  if [ -z "$api_key" ]; then
    echo "  (SKILLSMP_API_KEY not set)"
    return
  fi
  result=$(timeout 12 curl -s -X GET "https://skillsmp.com/api/v1/skills/search?q=$(echo "$QUERY" | sed 's/ /+/g')&limit=10" \
    -H "Authorization: Bearer $api_key" 2>/dev/null)
  echo "$result" | python3 -c "
import sys,json
d=json.load(sys.stdin)
for s in d.get('data',{}).get('skills',[]):
    print(f\"  {s.get('name','?')} ({s.get('author','?')}) - {str(s.get('description',''))[:80]}\")
" 2>/dev/null || echo "  (no results or rate limited)"
}

# --- 7. 168alphaclaw (Alibaba SkillHub) ---
search_alphaclaw() {
  echo "=== 168ALPHACLAW (SkillHub) ==="
  ALPHACLAW_BIN=""
  for path in "/data/npm-global/bin/alphaclaw" "$HOME/.local/bin/alphaclaw" "$(command -v alphaclaw 2>/dev/null)"; do
    [ -x "$path" ] && ALPHACLAW_BIN="$path" && break
  done
  if [ -z "$ALPHACLAW_BIN" ]; then
    echo "  (alphaclaw not found — install with: npm install -g 1688alphaclaw --prefix /data/npm-global)"
    return
  fi
  result=$($ALPHACLAW_BIN search "$QUERY" 2>/dev/null | grep -vE "^(用法:|命令:|全局选项:|示例:|环境变量:|SkillHub)" | grep -E '\S' | head -20)
  [ -n "$result" ] && echo "$result" || echo "  (no results)"
}

# --- 8. Local Hermes skills (2 depth levels) ---
search_local() {
  echo "=== LOCAL HERMES ==="
  FOUND=0
  for DIR in \
    "/home/ubuntu/.hermes/skills/skills" \
    "/home/ubuntu/.hermes/hermes-agent/optional-skills" \
    "/home/ubuntu/.hermes/hermes-agent/skills"; do
    [ ! -d "$DIR" ] && continue

    # depth 1: top-level skill dirs — match on SKILL.md content
    while IFS= read -r -d '' SKILL; do
      SKILL_NAME=$(basename "$SKILL")
      if grep -iq "$QUERY" "$SKILL/SKILL.md" 2>/dev/null; then
        echo "  * $SKILL_NAME"
        FOUND=$((FOUND+1))
      fi
    done < <(find "$DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

    # depth 2: subdirs (skills/, ecommerce/, etc.) — match on SKILL.md filename/content
    while IFS= read -r -d '' SUBDIR; do
      while IFS= read -r -d '' MD; do
        REL_PATH=$(echo "$MD" | sed "s|$DIR/||")
        if grep -iq "$QUERY" "$MD" 2>/dev/null; then
          echo "  * $REL_PATH"
          FOUND=$((FOUND+1))
        fi
      done < <(find "$SUBDIR" -mindepth 1 -maxdepth 1 -name "SKILL.md" -print0 2>/dev/null)
    done < <(find "$DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
  done
  [ $FOUND -eq 0 ] && echo "  (no local match)"
}

# --- Run all searches in sequence ---
echo "--- SKILLS.SH ---"
search_skills_sh

echo ""
echo "--- CLAWHUB ---"
search_clawhub

echo ""
echo "--- GITHUB ---"
search_github

echo ""
echo "--- AGENTSKILL.SH ---"
search_ags

echo ""
echo "--- SKILLHUB.CN ---"
search_skillhub

echo ""
echo "--- SKILLSMP ---"
search_skillsmp

echo ""
echo "--- 168ALPHACLAW (SkillHub) ---"
search_alphaclaw

echo ""
echo "--- LOCAL HERMES ---"
search_local