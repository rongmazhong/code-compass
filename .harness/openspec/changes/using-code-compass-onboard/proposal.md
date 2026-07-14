# Change: using-code-compass-onboard

## Why

> 柏拉图式发问的结论写在这里。说明真正要解决的问题、用户对象、成功信号。
> 明确"不做什么"（非目标）。

- 问题本质：agent 在加载 `using-code-compass` skill 时，旧流程只做"安装校验 + 无 .harness 则 init"，
  但（1）未显式判定项目是否已 init、（2）完全不报告项目当前状态、（3）不校验 AGENTS.md 路由段是否到位。
  导致 agent 接入后没有"下一步该做什么"的明确信号。
- 用户对象：使用 code-compass 的 agent / 开发者，在任意项目首次接入方法论时。
- 范围边界（MVP 必含）：
  1. 判定项目是否经 code-compass init，未 init 则自动初始化；
  2. 判定并内联报告项目状态（阶段机等）；
  3. 校验并自动补全 AGENTS.md 路由段。
- 非目标：不改动阶段机本身、不新增命令、不修改其它子 skill 的语义。
- 成功信号：运行 `code-compass using-code-compass` 后，未 init 项目自动完成 init，
  所有项目均打印一致的状态卡与下一步建议；重复运行幂等无副作用。

## What Changes

> 一句话概述本次变更触及的能力（对应 .harness/openspec/specs 下的 capability 名）。

增强 `using-code-compass` 命令与对应 SKILL.md：使其成为确定性的"接入校验 + 状态卡"入口，
复用 init / guard / status 共用的 `workflow-state.json` 真源。

## Impact

> 影响范围：哪些模块 / 命令 / 文档会变动。

- 命令：`code-compass using-code-compass`（cmd_use 重写）
- 新增辅助函数：`_next_step` / `_ensure_agents_md` / `_print_state_card`
- 文档：`skills/code-compass/skills/using-code-compass/SKILL.md`（改为 agent 可执行指令）
- 受影响既有逻辑：`cmd_init` 的 AGENTS 注入改为复用 `_ensure_agents_md`
