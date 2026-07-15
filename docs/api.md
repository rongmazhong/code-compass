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

## 能力 → 子 skill → 脚本 映射

本库没有 CLI 子命令。每个能力对应一个「**子 skill（意图触发）**」与一个「**scripts/ 脚本（机械执行）**」。
agent 在会话中按用户自然语言意图加载子 skill，子 skill 内部调对应 `bash scripts/x.sh`。

| 能力 | 触发意图（用户说法） | 子 skill | 对应脚本 | 调用方式 |
|------|----------------------|----------|----------|----------|
| 接入启用 | 「启用指南针 / 加载我的 skill 库 / using-code-compass」 | `skills/using-code-compass` | `scripts/use.sh` | `bash scripts/use.sh` |
| 初始化 | 「初始化 / init / 接入项目 / 首次使用」 | `skills/init` | `scripts/init-harness.sh` | `bash scripts/init-harness.sh` |
| 需求分析 | 「新功能 / 做客户端 / 实现 X / 需求分析 / 设计一下 / 出方案」 | `skills/product-analysis` | `scripts/product-analysis.sh` | `bash scripts/product-analysis.sh [name]` |
| 按 spec 开发 | 「开始实现 / 按 spec 开发 / 进入开发」 | `skills/dev` | `scripts/dev.sh`（内调 `guard.sh`+`worktree.sh`） | `bash scripts/dev.sh [name]` |
| worktree 管理 | 「查看 worktree / 清理 worktree」 | `skills/worktree` | `scripts/worktree.sh` | `bash scripts/worktree.sh list\|prune` |
| VAPD 标识 | 「记录 VAPD / 设置需求 ID / 缺陷编号 VB…」 | `skills/vapd` | `scripts/vapd.sh` | `bash scripts/vapd.sh [ID]` |
| 规范提交 | 「提交 / commit / 按规范提交」 | `skills/commit` | `scripts/commit.sh`（开头调 `guard.sh`） | `bash scripts/commit.sh [--exempt] <type> <描述...>` |
| 阶段闸门 | 「能否动手 / 校验阶段 / 现在能编码吗」 | `skills/guard` | `scripts/guard.sh` | `bash scripts/guard.sh` |
| 状态查看 | 「现在到哪 / 能否动手 / 继续流程 / 查看进度」 | `skills/status` | `scripts/status.sh` | `bash scripts/status.sh [--all\|activate\|--guard]` |
| QA 三连 | 「跑 QA / 验证覆盖 / 代码评审 / 做代码审查」 | `skills/qa` | `scripts/qa.sh` `scripts/verify.sh` `scripts/review.sh` | `bash scripts/qa.sh` 等 |
| 重建 wiki | 「更新文档 / 写 API 文档 / 同步 wiki」 | `skills/wiki` | `scripts/wiki.sh` | `bash scripts/wiki.sh [overview\|architecture\|modules\|api\|index]` |
| 刷新 harness | 「升级 / refresh harness / 配置漂移了」 | `skills/upgrade` | `scripts/upgrade.sh` | `bash scripts/upgrade.sh [--self]` |

> 说明：`scripts/state.sh` 是读写 `workflow-state.json` 的底层工具（`get`/`set`/`set-stage`/`set-vapd`），
> 主要供其他脚本与子 skill 复用，终端一般不直接调用。

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
