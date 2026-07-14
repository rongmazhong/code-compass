# 开发流程

> 由 `code-compass init` 生成，结合 code-compass 方法论。

## 标准工作流（code-compass 驱动）

```
idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary
```

1. **product-analysis**：运行 `code-compass product-analysis <name>`，柏拉图式发问确定需求范围，
    产出 `.harness/openspec/changes/<slug>/{proposal.md,tasks.md,specs/}`。
2. **dev**：运行 `code-compass dev <name>`，按 spec 进行
   计划拆解 → TDD（红-绿-重构）→ 子代理实现 → 验证。
3. 每阶段切换都更新 `.harness/state/workflow-state.json`，中断可断点续跑。

## 构建 / 测试 / 检查命令（探测所得）

- 构建：（未识别，请补充）
- 测试：（未识别，请补充）
- 静态检查：（未识别，请补充）
- 格式化：（未识别，请补充）

## 分支与提交

- 每个变更建议独立分支，命名与 `.harness/openspec/changes/<slug>` 对应
- 提交信息清晰描述"为什么"，而非仅"改了什么"
