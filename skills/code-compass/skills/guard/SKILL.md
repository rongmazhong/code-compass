---
name: guard
description: >
    阶段闸门校验：动手写代码前校验当前阶段是否允许进入开发。用户说「能否动手 / 校验阶段 / 现在能编码吗」或进入 dev / 写实现代码前的闸门自检时加载。
---

# guard —— 阶段闸门校验

`bash scripts/guard.sh`（或 `bash scripts/status.sh --guard`）把"先分析后开发"的软纪律硬化为硬约束：
在 agent 动手写代码前校验当前阶段是否允许进入开发。

## 触发条件

- 用户加载 `guard` 子 skill（agent 调 `bash scripts/guard.sh`；或 `bash scripts/status.sh --guard`）
- 用户问"现在能动手了吗"、"能否编码"、"校验阶段是否允许"
- 进入 `dev` / 写实现代码前的闸门自检

## 校验逻辑

- **通过**（exit 0）：`stage` 已达 `planned` 及之后，允许进入 `dev`。
- **拦截**（exit 1，黄色提醒）：`stage` 仍为 `idea` / `product-analysis`，尚未生成已确认 spec。
  agent 应停下先加载 `product-analysis` 子 skill。

## 豁免

- `bash scripts/dev.sh --force`：强制进入开发
- `bash scripts/commit.sh --exempt <type> <描述>`：跳过提交期阶段校验
- 环境变量 `CODE_COMPASS_GUARD=off`：关闭全部闸门（仅调试用）
