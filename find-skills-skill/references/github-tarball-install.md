# GitHub Tarball Install (When git clone Times Out)

**2026-05-19 validated:** `git clone github.com:<owner>/<repo>` times out (curl 28 after 132s), but `curl -sL "https://api.github.com/repos/<owner>/<repo>/tarball"` returns 200 with 316KB valid tarball.

## Why tarball beats git clone

- No git protocol (port 9418) required — only HTTPS (port 443)
- No SSH key negotiation
- No authentication
- Single HTTP GET, streams to file
- Works when git clone hangs on `Connecting to github.com... after 132407ms`

## Step-by-step

```bash
# 1. Download tarball (owner/repo from URL)
curl -sL "https://api.github.com/repos/<owner>/<repo>/tarball" -o /tmp/repo.tar.gz

# 2. Verify — size must be >1KB (error pages are tiny)
du -sh /tmp/repo.tar.gz
# ✅ 316K  = valid tarball
# ❌ 0     = error page

# 3. Extract to temp dir
mkdir -p /tmp/repo-extract && cd /tmp/repo-extract
tar -xzf /tmp/repo.tar.gz --strip-components=1
ls  # now contains repo root files directly

# 4. Inspect structure
ls <repo>/apps/  # common for monorepos
find . -name "package.json" | head -5
find . -name "SKILL.md" | head -5

# 5. Move to target location
mv /tmp/repo-extract /data/<repo-name>
```

## Verifying extracted content

```bash
# Verify it's not an error HTML page
file /tmp/repo.tar.gz
# Should say "gzip compressed data" — NOT "HTML document"

# Check first bytes
head -c 2 /tmp/repo.tar.gz | xxd
# gzip: 1f 8b  (standard)
# error: 3c 21 44 ("<!D")
```

## Known working case (2026-05-19)

- Repo: `mshk/mcp-rss-crawler`
- `git clone` → curl 28 timeout after 132s
- `curl .../tarball` → 200, 316KB, gzip verified
- Install attempt: succeeded extraction, but MCP required `sqlite3` native bindings + `bun` + Firecrawl API — not installable on server without compilation

## Limitation

The tarball contains the entire repo. If you only need one file, use the individual file API:

```bash
# Single file <1MB (not directory)
curl -s "https://api.github.com/repos/<owner>/<repo>/contents/<path>" \
  | python3 -c "import sys,json,base64; d=json.load(sys.stdin); print(base64.b64decode(d['content']).decode())"
```
