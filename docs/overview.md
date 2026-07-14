# 项目概览

> 由 code-compass 生成，已根据本项目实际情况补全。

## 这是什么

code-compass 是一套**个人 skill 库 + CLI**，提供 spec 驱动、状态机编排的开发方法论。
它把"先分析后开发"硬化为硬约束：动手写代码前必须先经 `product-analysis` 生成已确认
spec，`code-compass guard` 会在阶段不符时拦截偏离。

- 面向谁：使用 Claude / opencode 等 agent 的开发者，想用统一方法论管理多项目开发流程。
- 解决什么：避免"跳过分析就直接编码"，提供 idea→planned→dev→…→summary 的阶段机、
  VAPD 标识、规范化提交与断点续跑能力。

## 技术栈

- 语言：纯 Bash（POSIX 友好，CLI 为单文件脚本）
- 构建系统：无（不需要编译/依赖安装，分发给 agent 直接执行）
- 关键依赖：`jq`（解析 JSON 状态）、git（worktree / 提交）、标准 Unix 工具
- 分发：通过 `npx skills add rongmazhong/code-compass` 安装到 `~/.agents/skills/code-compass/`

## 快速开始

```bash
npx skills add rongmazhong/code-compass
alias code-compass="$HOME/.agents/skills/code-compass/code-compass"
code-compass using-code-compass      # 校验安装并初始化当前项目
code-compass init                    # 在当前项目生成 .harness/ 与 docs/
```

- 构建：无需构建
- 测试：（待补充，CLI 行为可用 `--help` 自验）
- 运行：`code-compass <command>`

## 相关文档

- 架构设计：architecture.md
- 核心模块：modules.md
- 功能与 API：api.md
- 下一步：运行 `code-compass product-analysis` 进入需求分析阶段
