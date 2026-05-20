# Skill Description 格式规范

## 原则

Hermes Agent 通过 `description` 字段判断是否触发 skill。描述应使用**自然语言**，列举用户实际会说的话，而不是罗列标签。

## ✅ 正确写法

```yaml
---
name: find-skills
description: "在多个 skill 市场中搜索 skill。当用户说：找 skill、搜素 skill、搜索 skill、安装 skill、查看有哪些 skill、聚合搜索 skill、帮我找 xxx 相关的 skill 时使用。"
---
```

- description 是完整句子，不是关键词列表
- 触发条件是"用户会说的话"，不是"触发词："
- 避免用"触发词：xxx、yyy"这种僵硬格式

## ❌ 错误写法

```yaml
---
description: "搜索 skill。触发词：找 skill、搜索 skill、聚合"
---
```

## 验证方法

改完后用 WebUI 搜索框测试，输入任意一个触发短语，确认能搜到这个 skill。

## 适用场景

所有 skill 的 frontmatter description 都适用本规范，特别是工具类 skill（搜索、邮件、文件处理等）。
