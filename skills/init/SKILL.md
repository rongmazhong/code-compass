---
name: init
description: |
  在当前项目初始化 code-compass 运行环境。当用户运行 `code-compass init`、
   或在新项目开始使用 code-compass 时触发。创建 .harness/ 目录（state + rules）、
  openspec/ 骨架，并向 AGENTS.md 注入 code-compass 路由指引。
---

# init

为当前项目铺设 code-compass 的运行基座：状态目录、项目规则、spec 存储与 agent 路由。

## 触发条件

- 用户运行 `code-compass init`
- 用户在新仓库中首次使用 code-compass
- `use-code-compass` 检测到目标项目缺少 `.harness/`

## 执行流程

1. 创建 `.harness/` 目录结构：
   - `config.json`：工具元信息（name、version、skills/spec/state/rules 目录约定）
   - `state/workflow-state.json`：初始阶段 `idea`，记录 `completed` / `spec` / `branch` / `updated_at`
   - `rules/`：项目规则（见下，由 init 探测项目后生成）
2. 探测目标项目（语言、构建系统、顶层目录、测试/检查命令），生成 `rules/` 三文件：
   - `rules/structure.md`：项目工程结构定义（技术栈 + 目录职责）
   - `rules/workflow.md` ：开发流程（构建/测试/检查命令、分支与提交约定）
   - `rules/coding.md`   ：编码约束（通用原则 + 语言相关规则）
3. 创建 `openspec/` 骨架：
   - `openspec/specs/`：当前能力 spec（truth）
   - `openspec/changes/`：待实现的变更提案
   - `openspec/project.md`：项目级上下文
4. 生成 `docs/` 项目 wiki（基于探测填充脚手架，agent 随后补全）：
   - `docs/INDEX.md`：索引，AI agent 先读本文件再深入各文档
   - `docs/overview.md`：项目概览（技术栈、快速开始）
   - `docs/architecture.md`：架构设计（目录布局、数据流）
   - `docs/modules.md`：核心模块（目录职责与边界）
   - `docs/api.md`：功能清单及 API 接口文档
4. 向 `AGENTS.md` 注入 code-compass 路由段（用 `MARKER` 包裹，避免重复）：
   - 说明四个命令：`use-code-compass` / `init` / `design` / `dev`
   - 说明 `.harness/state/workflow-state.json` 的阶段含义
   - 说明 `.harness/rules/` 三文件为开发/审查须遵循的项目规则

## 不覆盖原则

- 已存在的 `config.json` / `state/workflow-state.json` / `project.md` 不覆盖
- 已存在的 `rules/*.md` 不覆盖（仅首次生成，后续由人工维护）
- 已注入路由段的 `AGENTS.md` 跳过注入，仅追加一次

## 阶段状态（workflow-state.json）

```dot
digraph cc {
  rankdir=LR;
  idea -> design -> planned -> dev -> implemented -> qa -> verified -> reviewed -> shipped;
}

## 目录产出

```
.harness/
├── config.json
├── state/workflow-state.json
└── rules/
    ├── structure.md   # 项目工程结构定义
    ├── workflow.md    # 开发流程
    └── coding.md      # 编码约束

docs/                        # 项目 wiki（AI agent 入口）
├── INDEX.md                 # 索引
├── overview.md              # 项目概览
├── architecture.md          # 架构设计
├── modules.md               # 核心模块
└── api.md                   # 功能清单及 API 接口
```
```
