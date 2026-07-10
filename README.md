# code-compass

一个类似 [Superpowers](https://github.com/Geeksfino/superpowers) 的个人 skill 库。

## 简介

`code-compass` 是我个人的工程方法论与技能（skill）集合，用于在日常开发中沉淀可复用的流程、规范与最佳实践。其设计理念借鉴 Superpowers：

- **每个 skill 聚焦一类明确的任务或决策场景**，自带触发条件与执行流程；
- **强调方法论而非堆功能**，优先用正确的方式做事（TDD、系统化调试、计划驱动开发等）；
- **可被 agent 直接调用**，通过 `SKILL.md` 描述触发条件与步骤，在合适的时机自动加载。

## 目录结构

```
code-compass/
├── README.md              # 项目说明
└── <skill-name>/          # 单个 skill 目录
    └── SKILL.md           # skill 的触发条件与执行流程
```

## 使用方式

本仓库作为 agent 的 skills 来源之一被引用。当任务匹配某个 skill 的触发条件时，对应 `SKILL.md` 会被加载并指导执行。

## 设计原则

1. 先理解问题，再动手实现（brainstorm / plan 优先）。
2. 编码前写测试（TDD）。
3. 遇到 bug 先定位根因，再修复（systematic debugging）。
4. 完成前做验证（verification before completion）。

## License

MIT
