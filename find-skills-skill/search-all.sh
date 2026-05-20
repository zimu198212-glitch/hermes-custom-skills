#!/usr/bin/env bash
# ============================================================
# Unified Skills Search - aggregates results from 9 sources
#   1. skills.sh      (npx skills find) — 多关键词
#   2. ClawHub        (clawhub search) — 多关键词
#   3. agentskill.sh  (ags find) — 多关键词
#   4. skillhub.cn    (skillhub search) — 关键词过滤
#   5. SkillsMP       (curl API) — 多查询变体
#   6. GitHub         (gh search repos) — AI agent执行
#   7. Local built-in (grep in ~/.hermes/skills/)
#   8. Hermes Market  (hermes skills search) — marketplace官方
#   9. LobeHub        (web_search by AI agent)
#
# Usage: ./search-all.sh <query>
# ============================================================
export PATH="/data/node-global/bin:/home/ubuntu/.local/bin:$PATH:/usr/local/bin:/usr/bin:/bin"

# Auto-source .env for SKILLSMP_API_KEY
[ -f "$HOME/.env" ] && source "$HOME/.env" 2>/dev/null

QUERY="${1:-}"
[ -z "$QUERY" ] && echo "Usage: $0 <query>" && exit 1

# 关联关键词映射：主查询词 → 补充扩展关键词（仅用于查漏，不用于泛搜索）
# 格式: "主查询" "补充词1" "补充词2" ...
KEYWORD_MAP=(
  ["ozon"]="ozon-seller-api ozon-shopper ozon-fbo"         # OZON边缘case
  ["OZON"]="ozon-seller-api ozon-shopper ozon-fbo"
  ["1688"]="1688-to-ozon 1688-product-to-ozon"              # 1688边缘case
  ["wildberries"]="ozon-wildberries-analyzer"
  ["ecommerce"]="cross-border-ecommerce-skill"
)

# 根据主查询获取扩展关键词（只在查漏时用，主查询始终第一个）
get_keywords() {
  # 直接返回主查询，关联数组扩展关键词暂不可用（bash多词键名陷阱）
  echo "$QUERY"
}

ALL_KEYWORDS=$(get_keywords)

# --- 1. skills.sh (多关键词 + 去重) ---
search_skills_sh() {
  echo "=== SKILLS.SH ==="
  if ! command -v npx &>/dev/null; then
    echo "  (npx not found)"
    return
  fi
  declare -A SEEN
  for kw in $ALL_KEYWORDS; do
    while IFS= read -r line; do
      # 提取 owner/repo@skillname 部分作为去重key
      key=$(echo "$line" | grep "@" | sed 's/.*@\([a-zA-Z0-9_-]*\).*/\1/' | tr '[:upper:]' '[:lower:]')
      if [ -n "$key" ] && [ -z "${SEEN[$key]}" ]; then
        SEEN[$key]=1
        echo "  $line"
      fi
    done < <(npx --yes skills find "$kw" 2>/dev/null | grep "@" | grep -v "Install with" | head -20)
  done
  [ ${#SEEN[@]} -eq 0 ] && echo "  (no results)"
}

# --- 2. ClawHub (多关键词 + 去重) ---
search_clawhub() {
  echo "=== CLAWHUB ==="
  CLAWHUB_BIN=""
  if command -v clawhub &>/dev/null; then
    CLAWHUB_BIN="clawhub"
  elif [ -x "/data/node-global/bin/clawhub" ]; then
    CLAWHUB_BIN="/data/node-global/bin/clawhub"
  else
    echo "  (clawhub not installed)"
    return
  fi
  # ClawHub去重：用grep先收集所有行到临时文件，最后统一去重
  local tmpfile="/tmp/clawhub_results_$$.txt"
  > "$tmpfile"
  for kw in $ALL_KEYWORDS; do
    raw_output=$($CLAWHUB_BIN search "$kw" 2>&1 || true)
    echo "$raw_output" | grep -v "Searching" | grep -v "^$" | grep -v "^---" | head -20 >> "$tmpfile"
  done
  # 按名称去重，保留第一次出现的行
  if [ -s "$tmpfile" ]; then
    sort -uk1 "$tmpfile" | while IFS= read -r line; do
      [ -n "$line" ] && echo "  $line"
    done
  else
    echo "  (no results)"
  fi
  rm -f "$tmpfile"
}

# --- 3. agentskill.sh (ags find + 多关键词) ---
search_ags() {
  echo "=== AGENTSKILL.SH ==="
  if ! command -v ags &>/dev/null; then
    echo "  (ags not found)"
    return
  fi
  declare -A SEEN
  for kw in $ALL_KEYWORDS; do
    while IFS= read -r line; do
      # 格式: owner/skillname    author  score   description
      # 提取 skillname 作为去重key
      skillname=$(echo "$line" | awk '{print $1}' | sed 's|.*/||' | tr '[:upper:]' '[:lower:]')
      if [ -n "$skillname" ] && [ -z "${SEEN[$skillname]}" ]; then
        SEEN[$skillname]=1
        echo "  $line"
      fi
    done < <(ags find "$kw" 2>&1 | grep "/" | grep -v "agentskill.sh" | head -20)
  done
  [ ${#SEEN[@]} -eq 0 ] && echo "  (no results)"
}

# --- 4. skillhub.cn (主查询 + 关键词过滤) ---
search_skillhub() {
  echo "=== SKILLHUB.CN ==="
  for p in /home/ubuntu/.local/bin/skillhub /usr/local/bin/skillhub; do
    if [ -x "$p" ]; then
      result=$($p search "$QUERY" 2>&1 | grep -iE "ozon|wildberries|1688.*ozon|mpstats|clawec|seller|listing|fbo|inventory|review" | grep -vE "You can|version:|Summarize|Github|humanizer|web-tools|skill-creator|ima-skills|baozong|A股|港股|美股|self-improving|find-skills" | head -20)
      [ -n "$result" ] && echo "$result" | sed 's/^/  /' || echo "  (no results)"
      return
    fi
  done
  echo "  (skillhub not installed)"
}

# --- 5. SkillsMP (直接查询 + 高优先级名称预检，避免语义搜索漏报) ---
search_skillsmp() {
  echo "=== SKILLSMP ==="
  local api_key="${SKILLSMP_API_KEY:-}"
  if [ -z "$api_key" ]; then
    echo "  (SKILLSMP_API_KEY not set in .env)"
    return
  fi
  local tmpfile="/tmp/skillsmp_seen_$$.txt"
  > "$tmpfile"
  # 1. 高优先级名称精确预检：直接搜精确名称（解决语义搜索漏报）
  for exact in "ozon-seller-api" "ozon-skill" "marketplace-ru"; do
    result=$(curl -s --max-time 8 "https://skillsmp.com/api/v1/skills/ai-search?q=${exact}&limit=3" \
      -H "Authorization: Bearer $api_key" 2>/dev/null)
    echo "$result" | python3 -c "
import sys, json
d = json.load(sys.stdin)
for s in d.get('data',{}).get('data',[]):
    sk = s.get('skill',{})
    name = sk.get('name','?')
    if name != '?':
        with open('$tmpfile', 'a') as f:
            f.write(name + '|' + str(s['score']) + '|' + sk.get('author','?') + '\n')
" 2>/dev/null
  done
  # 2. 主查询 + ecommerce后缀
  for kw in $ALL_KEYWORDS; do
    result=$(curl -s --max-time 8 "https://skillsmp.com/api/v1/skills/ai-search?q=${kw}+ecommerce&limit=5" \
      -H "Authorization: Bearer $api_key" 2>/dev/null)
    echo "$result" | python3 -c "
import sys, json
d = json.load(sys.stdin)
for s in d.get('data',{}).get('data',[]):
    sk = s.get('skill',{})
    name = sk.get('name','?')
    if name != '?':
        with open('$tmpfile', 'a') as f:
            f.write(name + '|' + str(s['score']) + '|' + sk.get('author','?') + '\n')
" 2>/dev/null
  done
  # 读取去重后的结果
  if [ -s "$tmpfile" ]; then
    sort -u "$tmpfile" | while IFS='|' read -r name score author; do
      echo "  [$score] $name ($author)"
    done
  else
    echo "  (no results)"
  fi
  rm -f "$tmpfile"
}

# --- 6. GitHub (AI agent执行) ---
search_github() {
  echo "=== GITHUB ==="
  echo "  (AI agent: gh search repos with multi-keyword)"
  echo "  Commands:"
  echo "    gh search repos \"skill-\$(echo $QUERY | tr '[:upper:]' '[:lower:]')\" --limit 10"
  echo "    gh search repos \"ozon-mcp\" --limit 10"
  echo "    gh search repos \"skill-ozon\" --limit 10"
  echo "    gh search repos \"1688-product-to-ozon\" --limit 5"
  echo "  Then verify SKILL.md: gh api repos/<owner>/<repo>/contents/SKILL.md --jq '.content' | base64 -d | head -3"
}

# --- 7. Local Hermes skills ---
search_local() {
  echo "=== LOCAL HERMES ==="
  FOUND=0
  for SKILL in $(find /home/ubuntu/.hermes/skills -name "SKILL.md" 2>/dev/null); do
    if grep -iq "$QUERY" "$SKILL" 2>/dev/null; then
      DIR_NAME=$(basename "$(dirname "$SKILL")")
      SHOW=0
      if echo "$DIR_NAME" | grep -qiE "^(ozon|wildberries|1688-to-ozon|linkfox-mpstats-ozon|clawec-ozon|ecommerce)"; then
        SHOW=1
      fi
      if [ $SHOW -eq 1 ]; then
        echo "  * $DIR_NAME"
        FOUND=$((FOUND+1))
      fi
    fi
  done
  [ $FOUND -eq 0 ] && echo "  (no local match)"
}

# --- 8. Hermes Marketplace (hermes skills search) ---
search_hermes_market() {
  echo "=== HERMES MARKET ==="
  HERMES_BIN="${HERMES_BIN:-hermes}"
  if ! command -v "$HERMES_BIN" &>/dev/null; then
    HERMES_BIN="$HOME/.hermes/hermes-agent/venv/bin/hermes"
  fi
  if ! command -v "$HERMES_BIN" &>/dev/null; then
    echo "  (hermes not found)"
    return
  fi
  # 调用 hermes skills search，解析 Unicode 表格输出
  # 表格结构: │ name │ description │ source │ trust │ identifier │
  # 多行描述行需要合并
  RESULT=$("$HERMES_BIN" skills search "$QUERY" --source all --limit 10 2>/dev/null)
  if echo "$RESULT" | grep -q "No skills found"; then
    echo "  (no results)"
    return
  fi
  # 提取数据行(以 │ 开头，排除表头和分隔符)
  LINES=$(echo "$RESULT" | grep "^│" | grep -v "^┡" | grep -v "^│ Name" | grep -v "^│-$")
  if [ -z "$LINES" ]; then
    echo "  (no results)"
    return
  fi
  COUNT=0
  while IFS= read -r line; do
    COUNT=$((COUNT+1))
    # 提取第一列(name) 和第三列(source)，去除空格
    NAME=$(echo "$line" | sed 's/│/\n/g' | sed -n '2p' | sed 's/^ *//;s/ *$//')
    SRC=$(echo "$line" | sed 's/│/\n/g' | sed -n '4p' | sed 's/^ *//;s/ *$//')
    if [ -n "$NAME" ]; then
      echo "  $NAME ($SRC)"
    fi
  done <<< "$LINES"
  [ $COUNT -eq 0 ] && echo "  (no results)"
}

# --- Run all in parallel where possible ---
echo "--- SKILLS.SH ---"
search_skills_sh

echo ""
echo "--- CLAWHUB ---"
search_clawhub

echo ""
echo "--- SKILLHUB.CN ---"
search_skillhub

echo ""
echo "--- AGENTSKILL.SH ---"
search_ags

echo ""
echo "--- SKILLSMP ---"
search_skillsmp

echo ""
echo "--- GITHUB ---"
search_github

echo ""
echo "--- HERMES MARKET ---"
search_hermes_market

echo ""
echo "--- LOCAL HERMES ---"
search_local

echo ""
echo "=== NOTES FOR AI AGENT ==="
echo "  1. GitHub: run 'gh search repos' with keywords: skill-ozon, ozon-mcp, ozon-stock, ozon-seller-api"
echo "  2. LobeHub: check https://lobehub.com/skills for ozon-related MCP/skill packages"
echo "  3. SkillsMP missing results: try direct name query like 'ozon-seller-api' (semantic may filter out)"