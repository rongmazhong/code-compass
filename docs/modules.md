# 核心模块

> 由 code-compass 生成，已根据本项目实际情况补全。

## 子 skill 层（skills/code-compass/skills/）

每个子 skill 是一个独立目录，含 `SKILL.md`：`description` 为意图触发词，正文为方法论散文 + 调 `scripts/*.sh` 的机械步骤。

| 子 skill | 触发意图 | 调度的脚本 |
|----------|----------|------------|
| `using-code-compass` | 「启用指南针 / 加载我的 skill 库」 | `scripts/use.sh` |
| `init` | 「初始化 / init / 接入项目」 | `scripts/init-harness.sh` |
| `product-analysis` | 「新功能 / 需求分析 / 设计一下 / 出方案」 | `scripts/product-analysis.sh` |
| `dev` | 「开始实现 / 按 spec 开发」 | `scripts/dev.sh`（内调 `guard.sh`+`worktree.sh`） |
| `worktree` | 「查看 / 清理 worktree」 | `scripts/worktree.sh` |
| `vapd` | 「记录 VAPD / 设置需求 ID」 | `scripts/vapd.sh` |
| `commit` | 「提交 / commit / 按规范提交」 | `scripts/commit.sh`（开头调 `guard.sh`） |
| `status` | 「现在到哪 / 能否动手 / 查看进度」 | `scripts/status.sh` |
| `guard` | 「能否动手 / 校验阶段」 | `scripts/guard.sh` |
| `qa` | 「跑 QA / 验证覆盖 / 代码评审」 | `scripts/qa.sh` `verify.sh` `review.sh` |
| `wiki` | 「更新文档 / 同步 wiki」 | `scripts/wiki.sh` |
| `upgrade` | 「升级 / refresh harness」 | `scripts/upgrade.sh` |

## 工具层（skills/code-compass/scripts/）

可独立运行的 bash 脚本，是真正的机械执行体，被子 skill 调用，也可由终端用户直接运行。

| 脚本 | 职责 | 边界 |
|------|------|------|
| `_common.sh` | 共享实现 | 解析 `CC_ROOT`（软链感知）、承载 json/state/stages/detect/docs/worktree 等底层函数与 `cmd_*` 命令实现；被各脚本 `source`，不直接执行 |
| `init-harness.sh` | 初始化运行基座 | 生成 `.harness/`（state/rules/openspec）、`docs/` 脚手架、注入 AGENTS.md 路由段 |
| `product-analysis.sh` | 脚手架需求分析工作区 | 生成 `proposal.md`/`tasks.md`/`specs/`；`--append` 追加澄清、`--force` 直接建工作区 |
| `dev.sh` | 基于 spec 开发 | 开头调 `guard.sh` 闸门、调 `worktree.sh` 隔离；`--force` 强制进入 |
| `worktree.sh` | git worktree 管理 | `list` / `prune`，不触碰状态机 |
| `vapd.sh` | VAPD 标识 | 记录/查看 `vapd_id`（VR/VB/VT），写入 `workflow-state.json` |
| `commit.sh` | 规范提交 | 开头调 `guard.sh` 阶段校验；`<type>: #{VAPD_ID}#<描述>`；`--exempt` 跳过校验 |
| `status.sh` | 状态查看 | 状态卡 / `--all` 一览 / `activate` 下一步；`--guard` 复用闸门结果 |
| `guard.sh` | 阶段闸门 | 非 0 即拦截；被 `dev.sh`/`commit.sh` 内嵌调用，无独立 CLI 命令 |
| `qa.sh` / `verify.sh` / `review.sh` | QA 三连 | 各自按阶段推进状态机至 `verified`/`reviewed`/`summary` |
| `wiki.sh` | 重建 docs/ | 重建 `INDEX.md` 及 overview/architecture/modules/api 脚手架 |
| `upgrade.sh` | 刷新 harness | 合并 `config.json`+`workflow-state.json`；`--self` 从 `upgrade_source` 拉取 skill 库 |
| `use.sh` | 注册启用 | 安装校验 + init 校验 + AGENTS.md 校验 + 打印状态卡 |
| `state.sh` | 状态读写 | `get`/`set`/`set-stage`/`set-vapd`，供其它脚本/子 skill 复用 |

## 共享实现（skills/code-compass/scripts/_common.sh）

`lib/` 已移除，原共享函数已并入 `scripts/_common.sh`，被各 `scripts/<x>.sh` 在开头 `source` 复用，不再是独立 lib 层。

| 文件 | 职责 | 关键函数 |
|------|------|----------|
| `scripts/_common.sh` | JSON / 状态 / 阶段 / 探测 / 文档 / worktree 共享实现 | 原 `lib/json.sh` 的 `_json_valid` / `_json_get`(jq) / `_json_get_bash`(兜底) / `_json_set` / `_json_add_completed`；原 `lib/state.sh` 的 `_state_ensure_file` / `_state_migrate` / `_state_active` / `_state_list` / `_state_set` / `_set_stage` / `_set_track` / `_set_vapd`；原 `lib/stages.sh` 的 `_track_stages` / `_stage_chain` / `_next_stage_in_track` / `_stage_cmd` / `_can_code`（闸门）；原 `lib/detect.sh` 的 `_detect_project` / `_gen_rules` / `_dir_roles` / `_coding_rules` / `_gen_guard_rules` / `_fill_overview`；原 `lib/docs.sh` 的 `_gen_docs` / `_gen_index` / `_write_doc` / `_tree` / `_module_rows`；原 `lib/worktree.sh` 的 `_setup_worktree`；以及历史 `lib/cmds/` 命令实现（已并入） |

## 运行期模块（每个被管理项目的 .harness/）

| 目录/文件 | 职责 |
|-----------|------|
| `.harness/config.json` | `tracks`（research/small/standard/standard+/refactor）与 `stages` 阶段链、目录约定 |
| `.harness/state/workflow-state.json` | 状态机真源：`{tool, active, changes{<slug>:{stage,branch,track,vapd_id,updated_at,completed[]}}}` |
| `.harness/rules/` | `structure.md` / `workflow.md` / `coding.md` / `guard.md`（init 探测生成） |
| `.harness/openspec/specs/` | 能力级 spec（truth） |
| `.harness/openspec/changes/<slug>/` | 变更提案：`proposal.md` / `tasks.md` / `specs/<cap>/spec.md` |
| `.harness/issues.md` | `--append` 累积的澄清/决策单文件日志 |

## 模块关系

- 子 skill 描述「何时触发 + 怎么调脚本」；机械执行统一收敛到 `scripts/*.sh`，脚本内部 `source _common.sh` 复用底层函数。
- 所有脚本读写同一 `.harness/state/workflow-state.json`，保证 `guard`/`status`/`commit` 结果一致。
- `init-harness.sh` 通过 `_common.sh` 内的探测函数生成 `rules/` 与 AGENTS.md 路由段，使项目接入方法论。
- 无 CLI 主入口：`dev`/`commit` 子 skill 各自在开头调 `bash scripts/guard.sh` 强制「先分析后开发」。
