# Skill 来源识别指南

## 五类来源

| 类型 | 来源 | 安装方式 | 特征 |
|------|------|---------|------|
| A | Hermes 官方包 | 内置，随 Hermes 更新 | `~/.hermes/skills/` 根目录子目录 |
| B | 各 marketplace 安装 | clawhub/skillhub/ags + 移动到 `skills/skills/` | `skills/skills/` 子目录 |
| C | Alphaclaw 安装 | `alphaclaw install` → 装到 cwd 或 workspace | `workspace/skills/` |
| D | **Agent 自己创建** | 调试/排查时临时写 | 含诊断文件（`diagnostics-*.md`、`debug-*.py`） |
| E | GitHub clone | `gh repo clone` 或手动复制 | 需查 git log |

## 如何判断 skill 是自己写的 vs marketplace 安装的

**自己写的 skill 特征：**
- 路径：`skills/ecommerce/alphashop-1688-mcp/` 或类似 debug 路径
- 含诊断文件：`diagnostics-*.md`、`test_*.py`、`generate_jwt.py`
- 文件创建时间和调试记录吻合（今天的 session）
- 无 marketplace 元数据（无 `installs`、`downloads` 等字段）

**Marketplace skill 特征：**
- SKILL.md 含 `downloads`、`installs`、`★` 收藏数
- 有标准化 description（开头含平台/功能描述）
- 目录结构干净，无调试残留文件

## 经验法则

- `workspace/` 下的 skill → alphaclaw 安装后未移动的
- `skills/ecommerce/` 路径 → Hermes 官方包的一部分
- 含 `diagnostics-*` / `generate_jwt.py` / `test_*.py` → **自己写的调试产物，应删除**

## 2026-05-18 实例

- `alphashop-1688-mcp` → **自己写的**（含 diagnostics-2026-05-15.md, generate_jwt.py），已删除
- `ozon-store-weekly-report` → Alphaclaw 安装（干净，无调试文件）
- `ozon-niche-analyzer` → Alphaclaw 安装（干净，无调试文件）
- `1688-product-search` → ClawHub 安装（/data/hermes/skills/skills/）
