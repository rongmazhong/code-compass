---
name: wiki
description: >
    更新或重建项目 wiki（docs/）。用户说「更新文档 / 写 API 文档 / 同步 wiki / 补架构说明」或实现完功能需同步 docs 时加载。
---

# wiki —— 项目 wiki 更新

`docs/` 是项目的可机读知识库。AI agent 在开始理解或改动项目前，应先读
`docs/INDEX.md` 建立全局认知，再按需深入概览/架构/模块/API。

## 触发条件

- 用户加载 `wiki` 子 skill（agent 调 `bash scripts/wiki.sh [topic]`）
- 用户说"更新文档"、"补架构说明"、"写 API 文档"
- 实现完一个功能后，需要同步 `docs/api.md` 与 `docs/modules.md`

## 文档集合（init 生成脚手架，agent 补全）

| 文档 | 内容 | 何时更新 |
|------|------|----------|
| `docs/INDEX.md` | 索引与快速理解路径 | 每次 `wiki` 自动重建 |
| `docs/overview.md` | 项目概览 | 项目定位/技术栈变化时 |
| `docs/architecture.md` | 架构设计 | 分层/数据流/选型变化时 |
| `docs/modules.md` | 核心模块 | 新增/重构模块时 |
| `docs/api.md` | 功能清单与 API | 新增/修改对外接口时 |

## 执行流程

1. `bash scripts/wiki.sh`：重建 `INDEX.md` 并补建缺失文档（不覆盖已有内容）。
2. `bash scripts/wiki.sh <overview|architecture|modules|api>`：重建指定文档脚手架。
3. agent 读取相关**源码**，将脚手架中的占位（`__...__`、待补充）替换为真实信息：
   - 概览：补"解决什么问题、为谁"
   - 架构：补实际分层、调用链、关键权衡
   - 模块：补各模块真实职责与关键文件
   - API：列出真实接口（方法/路径/请求响应/契约）
4. 更新后保持 `INDEX.md` 的"快速理解路径"有效。

## 原则

- **索引优先**：agent 与人都先读 `INDEX.md`
- **跟随代码**：文档与实现同步演进，避免陈旧
- **可验证**：API 文档应与实际路由/导出一致
