# Change: status-activate-cmd

## Why

> `code-compass status activate`（代码 `:849-859`）当前仅打印 `_stage_action` 的文字描述告诉 agent"下一步该做什么"，但不给出可直接复制执行的命令。agent 仍需自行判断并拼装命令，增加上下文切换成本与误用概率。

- 问题本质：`status activate` 是"提示"而非"可执行指令清单"。
- 用户对象：断点续跑的 AI agent。
- 范围边界（MVP 必含）：按 stage/track 输出对应可复制命令。
- 非目标：CLI 不直接 exec 对应 skill（skill 由 agent 加载）；不改阶段语义。
- 成功信号：运行 `code-compass status activate`（stage=planned）输出 `code-compass dev <slug>` 这类可直接复制的命令。

## What Changes

> 触及能力：status-activate（断点续跑命令输出）。

## Impact

> 影响范围：`skills/code-compass/code-compass` 的 `_stage_action`/`status activate` 渲染逻辑。

## Dependencies / Ordering

> 依赖 `parallel-state`（取 active slug 填入命令）、`sop-tiers`（按 track 裁剪显示哪些命令）、`qa-automation`（qa/verify/review 命令存在）。
