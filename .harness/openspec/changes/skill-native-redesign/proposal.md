# proposal.md — skill-native-redesign

## 问题本质

code-compass 当前的「优雅性」问题根源不在命令名，而在**控制流错位**：agent 想执行某个能力，
必须先 shell 出去跑 `code-compass <cmd>`，而该 CLI 大多只是 `mkdir` + 写 JSON + 打印
「去读 `skills/<cmd>/SKILL.md`」。真实方法论全在 markdown 里。这造成三重间接与泄漏抽象：

1. **CLI 是多余中间人**：skill 本应触发即加载 SKILL.md，现在却要先经 bash 再绕回 markdown。
2. **硬约束靠 CLI 退出码**：「先分析后开发」的纪律被写在 `guard`/`commit` 的独立命令里，而非子 skill 散文。
3. **每步都要记精确命令**：`init`/`worktree`/`vapd`/`commit`/`status`/`guard`/`wiki`/`qa`… 一多就散；
   且安装需 alias/PATH/python3 前置，使用方法论本身被强加终端门槛。

对照 skill-creator 原则（渐进式披露、自包含方法、description 即触发、重复活封成 scripts、解释 why），
正确形态应是：**纯 skill 库**——子 skill 为一等公民，agent 按意图直接加载并照散文执行；
机械/确定性活（建目录、读写 state、git worktree、commit 格式化）封成 `scripts/*`，由 agent 在子 skill
内部按需调用；CLI 调度器彻底移除。

## 档位（tier）

**refactor（重构）+ 架构改造**——目标不是新增功能，而是把「CLI 中枢」重排为「skill 库 + scripts 工具层」。
成功后走 `qa → verified → reviewed`。

## 关键决策（已与用户确认）

1. **取代/合并 `cli-modular`**：原 `cli-modular`（把单文件 bash 拆 `lib/*.sh`、仍保留 CLI 为调度中枢）
   被本方案取代。其合理诉求（内部关注点拆分、测试先行）吸收为本方案的 `scripts/` 工具层 + `bats` 回归，
   但 **不再保留任何顶层 `code-compass` 命令**。
2. **彻底移除 CLI**：`skills/code-compass/code-compass` 可执行文件删除；终端用户改用 `scripts/*` 直跑，
   不再提供 `code-compass <cmd>` 命令，也不再要求 alias/PATH/python3。
3. **子 skill 为一等公民**：12 个能力各自成为独立子 skill，description 改为意图触发（pushy），
   不再以「运行 code-compass X」为首选触发语。
4. **机械活封 `scripts/`**：建脚手架 / 读写 state / 闸门 / worktree / commit / wiki / vapd 抽成独立脚本，
   agent 在子 skill 内部调用；脚本也可被终端用户直接 `bash scripts/x.sh` 运行。
5. **硬约束下沉**：「先分析后开发」由 `dev`/`commit` 子 skill 在开头调用 `scripts/guard.sh` 并解释 why 来强制，
   无独立 `guard` 命令。
6. **状态/schema 兼容**：`workflow-state.json` 与 `config.json`（tracks/stages）schema 不变，
   `state.sh` 复用现有 jq→bash 兜底；已 init 的存量项目不因移除 CLI 而失效。

## 非目标（边界）

- 不新增任何用户可见功能；本次只重排架构与触发方式。
- 不删除 `jq → bash` 兜底、不重新引入 python3 作为前置依赖。
- 不改动 `workflow-state.json` / `config.json` 的既有 schema（仅确保 `state.sh` 路径正确）。
- 不重写方法论散文的「业务规则」（档位链、VAPD 格式等保持原样），只改其**承载位置与触发方式**。
- 不改动 `openspec/` spec 本身的写法规约。

## 成功信号（可观测）

- 仓库内不再存在任何 `code-compass` 可执行文件，README/AGENTS.md 无 `code-compass <cmd>` 调用示例。
- 12 个子 skill 的 description 均为意图触发、可经 skill-creator `run_loop` 触发率评测达标。
- agent 加载 `product-analysis` 子 skill 后，按散文执行即可完成 8 步并生成 spec，无需 shell 出 CLI。
- `scripts/guard.sh` 在 `idea`/`product-analysis` 阶段非 0 退出（拦截），`planned` 及以后 0 退出（放行）；
  `dev`/`commit` 子 skill 开头即调用它。
- `bash scripts/init-harness.sh` 在空项目生成 `.harness/`+`docs/`+AGENTS 路由，幂等（重复跑无副作用）。
- 存量已 init 项目：移除 CLI 后，`workflow-state.json`/`openspec/` 仍可正常读取与续跑。
- `bats`（或 `bash -n` + smoke）覆盖 init 幂等 / guard 闸门 / commit VAPD 格式 / state 读写，全绿。

## 与 cli-modular 的关系

`cli-modular`（当前标记 `verified`，但 `completed: []`）被**本方案取代并退休**。其测试先行诉求并入本方案 R8。
