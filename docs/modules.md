# 核心模块

> 由 code-compass 生成，已根据本项目实际情况补全。

## CLI 模块（skills/code-compass/）

| 模块/文件 | 职责 | 关键函数 / 边界 |
|-----------|------|----------------|
| `code-compass` | CLI 主入口 | bootstrap（`_resolve_dir` 解析 `CC_ROOT`）、`source lib/*.sh`+`lib/cmds/*.sh`、命令分发 `case "$cmd"`；被 `source` 时不触发分发 |
| `lib/json.sh` | JSON 读写 | `_json_valid` / `_json_get`(jq) / `_json_get_bash`(兜底) / `_json_set` / `_json_add_completed`；**jq 缺失时回退 bash**，不破坏无依赖分发 |
| `lib/state.sh` | 状态文件 | `_state_ensure_file` / `_state_migrate`(旧结构迁移) / `_state_active` / `_state_list` / `_state_set` / `_set_stage` / `_set_track` / `_set_vapd` |
| `lib/stages.sh` | 阶段与 track | `_track_stages`（取 track 阶段链）/ `_stage_chain` / `_next_stage_in_track` / `_stage_cmd`（下一步可复制命令）/ `_can_code`（闸门） |
| `lib/detect.sh` | 项目探测 | `_detect_project` / `_gen_rules` / `_dir_roles` / `_coding_rules` / `_gen_guard_rules` / `_fill_overview`；`init` 时生成 `rules/` 与 `AGENTS.md` 路由 |
| `lib/docs.sh` | wiki 生成 | `_gen_docs` / `_gen_index` / `_write_doc` / `_tree` / `_module_rows`；`wiki` 时重建 `docs/` |
| `lib/worktree.sh` | worktree | `_setup_worktree`；`dev` 时创建/复用 `<父目录>/worktrees/<slug>` |
| `lib/cmds/use.sh` | `using-code-compass` | `cmd_use`：安装校验 + init 校验 + AGENTS.md 校验 + 打印状态卡 |
| `lib/cmds/init.sh` | `init` | `cmd_init` / `_ensure_agents_md` |
| `lib/cmds/product-analysis.sh` | `product-analysis` | `cmd_product_analysis` / `_append_issue`（`--append`/`--force`） |
| `lib/cmds/dev.sh` | `dev`/`develop` | `cmd_dev`（含 `--force` 与阶段闸门） |
| `lib/cmds/worktree.sh` | `worktree` | `cmd_worktree`（`list`/`prune`） |
| `lib/cmds/vapd.sh` | `vapd` | `cmd_vapd` |
| `lib/cmds/commit.sh` | `commit` | `cmd_commit` / `_is_vapd`（`--exempt` 豁免 + 阶段校验） |
| `lib/cmds/wiki.sh` | `wiki` | `cmd_wiki` |
| `lib/cmds/guard.sh` | `guard` | `cmd_guard` |
| `lib/cmds/status.sh` | `status` | `cmd_status` / `_next_step` / `_print_state_card`（`--all` / `activate`） |
| `lib/cmds/qa.sh` | `qa`/`verify`/`review` | `cmd_qa` / `cmd_verify` / `cmd_review` / `_wf_cmd`（状态机推进） |
| `lib/cmds/help.sh` | `help` | `cmd_help` |

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

- 主入口 `source` 全部 `lib/*.sh` 与 `lib/cmds/*.sh`；命令实现（`cmd_*`）调用关注点库
  （如 `cmd_commit` 调 `_state_get` 取 `vapd_id`、`cmd_status` 调 `_track_stages`/`_stage_cmd`）。
- 所有模块读写同一 `.harness/state/workflow-state.json`，保证 `guard`/`status`/`commit` 结果一致。
- `init` 通过 `lib/detect.sh` 生成 `rules/` 与 `AGENTS.md` 路由段，使项目接入方法论。
