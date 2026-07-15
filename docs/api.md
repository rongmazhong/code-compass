# 功能清单及 API 接口

> 由 code-compass 生成，已根据本项目实际情况补全。

## 功能清单

- [x] **using-code-compass**：接入总入口——校验安装、init、补 AGENTS.md 路由、打印状态卡
- [x] **init**：初始化 `.harness/`（state/rules/openspec）、`docs/` 脚手架、注入 AGENTS.md 路由段
- [x] **product-analysis**：柏拉图式发问收敛需求，生成 `proposal.md`/`tasks.md`/`specs/`；`--append` 追加澄清、`--force` 直接建工作区
- [x] **dev / develop**：基于 spec 开发，自动创建/复用 git worktree；`--force` 强制进入
- [x] **worktree**：管理开发用 worktree（`list` / `prune`）
- [x] **vapd**：记录/查看 VAPD 标识（VR 需求 / VB 缺陷 / VT 任务）
- [x] **commit**：按 `<type>: #{VAPD_ID}#<描述>` 规范提交（含阶段校验）；`--exempt` 跳过校验
- [x] **guard**：阶段闸门校验（idea/product-analysis 拦截，planned+ 放行）
- [x] **status**：查看阶段进度；`--all` 一览多变更；`activate` 输出下一步可复制命令
- [x] **qa / verify / review**：QA 自动化三连，按阶段推进状态机
- [x] **wiki**：重建 `docs/INDEX.md`；`wiki <overview|architecture|modules|api>` 重建指定文档脚手架

## CLI 接口（子命令 → 函数）

| 命令 | 参数 | 说明 | 落点 |
|------|------|------|------|
| `using-code-compass` | — | 接入校验 + 状态卡 | `lib/cmds/use.sh: cmd_use` |
| `init` | — | 初始化当前项目 | `lib/cmds/init.sh: cmd_init` |
| `product-analysis` | `[name]` / `--append "文本"` / `--force <name>` | 需求分析；追加澄清 / 强制建工作区 | `lib/cmds/product-analysis.sh` |
| `dev` / `develop` | `[name]` / `--force <name>` | 基于 spec 开发（worktree 隔离） | `lib/cmds/dev.sh: cmd_dev` |
| `worktree` | `list` / `prune` | 管理 worktree | `lib/cmds/worktree.sh: cmd_worktree` |
| `vapd` | `[ID]` | 记录/查看 VAPD 标识 | `lib/cmds/vapd.sh: cmd_vapd` |
| `commit` | `[--exempt] <type> <描述...>` | 规范提交（阶段校验） | `lib/cmds/commit.sh: cmd_commit` |
| `guard` | — | 闸门校验（非 0=拦截） | `lib/cmds/guard.sh: cmd_guard` |
| `status` | `[--all]` / `[activate]` / `[--guard]` | 状态卡 / 一览 / 下一步 | `lib/cmds/status.sh: cmd_status` |
| `qa` | — | 自动化 QA（端到端 + 检查），推进至 `verified` | `lib/cmds/qa.sh: cmd_qa` |
| `verify` | — | 验证 spec 覆盖（tasks 勾选），推进至 `reviewed` | `lib/cmds/qa.sh: cmd_verify` |
| `review` | — | 代码评审，推进至 `summary` | `lib/cmds/qa.sh: cmd_review` |
| `wiki` | `[overview\|architecture\|modules\|api\|index]` | 重建 wiki | `lib/cmds/wiki.sh: cmd_wiki` |
| `help` / `--help` / `-h` | — | 帮助 | `lib/cmds/help.sh: cmd_help` |

## 对外契约

- **状态真源**：`.harness/state/workflow-state.json` 结构
  ```
  { "tool", "active": <slug>,
    "changes": { "<slug>": { stage, branch, track, vapd_id, updated_at, completed[] } } }
  ```
- **提交信息契约**：`<type>: #{VAPD_ID}#<描述>`；`vapd_id` 为空时退化为 `<type>: <描述>`。
- **track 契约**：`config.json.tracks` 取值 `research`/`small`/`standard`/`standard+`/`refactor`，
  决定阶段链（如 `small` 跳过 `review`）。
- **退出码**：`guard` 通过=0 / 拦截=非 0；`status`/`qa` 等成功=0。
