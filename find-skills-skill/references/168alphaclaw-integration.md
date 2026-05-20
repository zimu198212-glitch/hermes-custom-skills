# 168alphaclaw Integration (2026-05-18)

## Package

- npm: `1688alphaclaw` (not `alphaclaw`)
- binary: `alphaclaw` at `/data/npm-global/bin/alphaclaw`
- version: 1.1.6

## Install

```bash
npm install -g 1688alphaclaw --prefix /data/npm-global
```

## Key commands

```
alphaclaw search "<keyword>"   # search skills
alphaclaw install <name>        # install
alphaclaw login                # login
alphaclaw whoami               # current user
```

## Output format

Emoji animal prefix (🦐) + Chinese "找到 N 个技能". Skill entries include:
- name + version
- description
- download count + star count

## Filter noise lines

```bash
grep -vE "^(用法:|命令:|全局选项:|示例:|环境变量:|SkillHub|🦐 正在搜索)"
```

## Binary path resolution (for scripts)

```bash
for path in "/data/npm-global/bin/alphaclaw" "$HOME/.local/bin/alphaclaw" "$(command -v alphaclaw 2>/dev/null)"; do
  [ -x "$path" ] && ALPHACLAW_BIN="$path" && break
done
```
