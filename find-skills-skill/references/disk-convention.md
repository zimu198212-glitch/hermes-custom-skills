# File Output Convention — Data Disk First

**Rule: All generated files → `/data/` (data disk), system disk (`/dev/vda2`) for OS/system only.**

## Why
- System disk: 40GB — tight, hosts OS, Hermes, Node.js, Python
- Data disk: 30GB `/dev/vdb` — available for outputs

## Default Paths

| File type | Path |
|-----------|------|
| Reports, docs | `/data/documents/` |
| Workspace | `/data/workspace/` |
| Scripts | `/data/scripts/` |
| Skills (npm global) | `/data/npm-global/` |
| Skills (Hermes) | `/data/hermes/skills/` |
| Audio/memos | `/data/memos/` |

## Anti-patterns
- `/home/ubuntu/workspace/` ❌ — system disk
- `$HOME/` ❌ — system disk
- `~/.hermes/` symlink → `/data/.hermes/` ✅

## Verification
```bash
df -h /data   # confirm data disk mount
df -h /       # confirm system disk usage
```

## After Moving Files
Always update memory:
```
数据盘优先：所有生成文件默认写/data，系统盘仅存系统依赖。
```
