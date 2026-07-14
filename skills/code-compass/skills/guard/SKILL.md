---
name: guard
description: >
   阶段闸门校验：动手写代码前校验当前阶段是否允许进入开发。运行 `code-compass guard` 或说"能否动手 / 校验阶段 / 现在能编码吗"时触发。
---

# guard —— 阶段闸门校验

`code-compass guard`（或 `code-compass status --guard`）把"先分析后开发"的软纪律硬化为硬约束：
在 agent 动手写代码前校验当前阶段是否允许进入开发。

## 触发条件

- 用户运行 `code-compass guard` 或 `code-compass status --guard`
- 用户问"现在能动手了吗"、"能否编码"、"校验阶段是否允许"
- 进入 `dev` / 写实现代码前的闸门自检

## 校验逻辑

- **通过**（exit 0）：`stage` 已达 `planned` 及之后，允许进入 `dev`。
- **拦截**（exit 1，黄色提醒）：`stage` 仍为 `idea` / `product-analysis`，尚未生成已确认 spec。
  agent 应停下先运行 `code-compass product-analysis <name>`。

## 豁免

- `code-compass dev --force`：强制进入开发
- `code-compass commit --exempt <type> <描述>`：跳过提交期阶段校验
- 环境变量 `CODE_COMPASS_GUARD=off`：关闭全部闸门（仅调试用）
