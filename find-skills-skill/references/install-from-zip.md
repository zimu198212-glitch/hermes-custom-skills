# Install Skill from Zip (GitHub Blocked)

When `git clone` of a GitHub repo times out and user has uploaded a `.zip` instead:

## Workflow

1. **User uploads zip** → saved to `~/.hermes/cache/documents/`
2. **Identify SKILL.md location inside zip:**
   ```bash
   unzip -l <zip> | grep SKILL.md
   ```
3. **Extract to target dir** (usually `~/.hermes/skills/<slug>/`):
   ```bash
   unzip -o <zip> "<repo>/integrations/<target>/SKILL.md" -d /tmp/
   mv /tmp/<repo>/integrations/<target> ~/.hermes/skills/<slug>
   rm -rf /tmp/<repo>
   ```
4. **Rename frontmatter `name`** if collision with bundled skill (see SKILL.md § WebUI Visibility)
5. **For Loci/Loci-brain specifically** — also extract brain template files:
   ```bash
   mkdir -p ~/.loci && echo "$HOME/loci" > ~/.loci/brain-path
   mkdir -p ~/loci
   unzip -o <zip> "<repo>/plan.md" "<repo>/me/*" "<repo>/tasks/*" "<repo>/decisions/*" "<repo>/inbox.md" "<repo>/.loci/*" -d /tmp/
   cp -r /tmp/<repo>/. ~/loci/
   ```

## GitHub API Rescue (if zip not available)

```bash
# Get repo tree
curl -s "https://api.github.com/repos/<owner>/<repo>" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(d.get('clone_url'), d.get('default_branch'))
"

# Get file content via API
curl -s "https://api.github.com/repos/<owner>/<repo>/contents/<path>" | python3 -c "
import sys,json,base64
d=json.load(sys.stdin)
print(base64.b64decode(d['content']).decode())
"
```

## Common Zip Structures for Skills

| Source | Skill path in zip |
|--------|-------------------|
| ClawHub/OpenClaw | `<repo>/integrations/openclaw/skill/SKILL.md` |
| loci-brain (Loci) | `<repo>/integrations/openclaw/skill/SKILL.md` |
| Loci Lite | `<repo>/integrations/openclaw-lite/SKILL.md` |

Always `head -5` the SKILL.md before placing — some zips have the skill nested deeper.
