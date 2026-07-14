# 方法论强制契约（guard）

> 由 `code-compass init` 生成。本文件把「方法论优先」从软建议硬化为 agent 必须遵循的约束。

## 1. 硬默认：先分析后开发

任何代码改动意图，默认先走 `product-analysis → planned → dev` 阶段机：

```
idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary
```

- `stage` 仍在 `idea` / `product-analysis` = 尚未确认 spec，**禁止进入编码**。
- 动手前先跑 `code-compass guard`（或 `code-compass status --guard`）做闸门校验。

## 2. 触发词 → 必调 skill

| 意图 / 触发词 | 必调 skill |
|---------------|-----------|
| 新功能 / 做客户端 / 加能力 / 实现 X / 需求 | `product-analysis` |
| 改需求 / 调范围 / 设计一下 / 出方案 | `product-analysis` |
| 按 spec 实现 / 开始开发 / 进入开发 | `dev` |
| 提交 / commit | `commit` |
| 查看进度 / 继续流程 | `status` / `status activate` |
| 我要动手 / 是否可编码 | `guard` |

检测到代码改动意图且尚无 spec 时，**优先调 `product-analysis`**，而非直接编辑。

## 3. 「继续 / 直接做」闸门

`stage` 仍处 `idea` / `product-analysis` 时，用户说「继续 / 直接做 / 做吧」等，
agent 不得直接进入编码；先产出 spec 骨架或澄清清单，再继续。

## 4. 偏离提醒

准备写代码而 `state` 仍处 `idea` / `product-analysis`，`code-compass guard` 会输出黄色提醒
并以非 0 退出（视为偏离）。agent 应停下先走 `product-analysis`，或显式豁免并说明理由。

## 5. 豁免机制

- `code-compass dev --force`：强制进入开发。
- `code-compass commit --exempt <type> <描述>`：跳过提交期阶段校验。
- 环境变量 `CODE_COMPASS_GUARD=off`：关闭全部闸门（仅调试用）。
