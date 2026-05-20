# Auto-Upgrade Skill 研究 (2026-05-20)

## 结论

**没有专门为Hermes写的自动升级skill。**

唯一接近兼容的是 `agent-skills-auto-updater`（GitHub: Lucker-QY），但：
- 只支持**git仓库类型**的skill
- Hermes大部分skill是直接目录安装（无`.git`），不适用
- 已在 `~/.hermes/skills/agent-skills-auto-updater/` 手动安装

## 调研结果

### ✅ 可能兼容（需验证）
| Skill | 来源 | 描述 |
|-------|------|------|
| `agent-skills-auto-updater` | GitHub | 支持 `--root` 指定任意目录，扫描git-backed skill并fast-forward更新 |

### ❌ OpenClaw专用（不兼容Hermes）
几乎所有ClawHub上的 `auto-updater` 系列都依赖OpenClaw机制：
- `skill-auto-updater` — 依赖 `OPENCLAW_SKILLS_DIR` + `clawhub update`
- `skills-updater` — 同上
- `openclaw-auto-updater` (skills.sh 896 installs) — OpenClaw专用

### ⚠️ 局限性
Hermes skill目录状态（2026-05-20验证）：
```bash
find ~/.hermes/skills -maxdepth 3 -name ".git"  # → 0 结果
```
- `libtv-skills` — 是git仓库，有本地修改（跳过）
- `plur` — 是git仓库，有本地修改（跳过）
- 其余skill — **都不是git仓库**，无法用此工具升级

## 安装过程（GitHub网络故障时的Workaround）

**问题：** `git clone` 和 `curl tarball` 都超时

**解决：** 用 `gh api` 获取单个文件内容

```bash
# 1. 获取目录列表
gh api repos/Lucker-QY/agent-skills-auto-updater/contents --jq '.[].name'

# 2. 获取单个文件（base64编码）
gh api repos/Lucker-QY/agent-skills-auto-updater/contents/SKILL.md --jq '.content' | base64 -d

# 3. 写文件
gh api ... --jq '.content' | base64 -d > target/path/file.py
```

## 脚本Bug修复

### Bug 1: discover_repos 收到字符串而非Path对象
```python
# 症状: AttributeError: 'str' object has no attribute 'exists'
# 原因: --root 参数传入的是字符串列表，但 discover_repos 期望 Path 对象
# 修复: 
root = Path(root).expanduser()  # 在 iterdir 前加这行
```

### Bug 2: git fetch 对无remote的仓库挂起
```python
# 症状: git fetch 永久挂起（无remote时）
# 修复: 先检查 remote 是否存在
remote_result = run_git(repo, ["remote", "-v"], 5)
has_remote = bool(remote_result.stdout.strip())
if has_remote:
    fetch_result = run_git(repo, ["fetch"], timeout)
else:
    fetch_err = "(no remote)"
```

### Bug 3: Hermes agent未在已知root列表中
```python
# 修复: known_roots() 中添加 "hermes"
candidates = {
    ...
    "hermes": [user_home / ".hermes" / "skills"],
}
```

## 验证命令

```bash
# 检查更新（不修改）
python3 ~/.hermes/skills/agent-skills-auto-updater/scripts/agent_skills_auto_updater.py update --check --agent hermes --timeout 5

# 应用更新（fast-forward only）
python3 ~/.hermes/skills/agent-skills-auto-updater/scripts/agent_skills_auto_updater.py update --apply --agent hermes --timeout 5

# 检查哪些skill是git仓库
find ~/.hermes/skills -maxdepth 3 -name ".git" -type d
```

## 定时任务设置

如需定时执行，用cron：
```bash
# 每周一凌晨3点检查Hermes skill更新
0 3 * * 1 python3 ~/.hermes/skills/agent-skills-auto-updater/scripts/agent_skills_auto_updater.py update --check --agent hermes --timeout 10 >> ~/.hermes/logs/skill-update.log 2>&1
```
