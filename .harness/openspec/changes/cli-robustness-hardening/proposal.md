# Change: cli-robustness-hardening

## Why

- **问题本质**：`code-compass` CLI 存在 7 处正确性与健壮性问题，削弱了方法论闸门与状态机的可靠性——文档承诺的 `CODE_COMPASS_GUARD=off` 未实现；对 `python3` 硬依赖导致无 python 环境完全瘫痪；`cmd_status` 多次起 python 子进程且字段缺失会 `KeyError` 中断；状态文件损坏会被误判为"阶段偏离"假拦截；`product-analysis` 留下字面量 `<capability>` 占位目录造成"假 spec"；worktree 路径外置于项目父目录；状态文件非原子写可能写坏 JSON。
- **用户对象**：使用该 CLI 的 agent 与开发者；尤其在没有 `python3` 的极简容器 / CI、状态文件损坏、跨目录 worktree 协作等场景。
- **范围边界（MVP 必含）**：
  - P0 正确性：`CODE_COMPASS_GUARD=off` 真正生效。
  - P1 健壮性：去除 `python3` 硬依赖（优先 `jq`，纯 bash 兜底）；`cmd_status` 单次解析并兜底；区分"未初始化"与"状态文件损坏"。
  - P2 体验：`product-analysis` 默认 spec 落点消除字面量占位；worktree 内聚到 `TARGET_DIR/.worktrees/`；状态文件原子写入。
- **非目标**：不改变方法论阶段链与闸门语义；不引入测试框架 / CI；不重写 CLI 为其他语言；不新增命令。
- **成功信号**：
  - 无 `python3` 环境下 `init` / `dev` / `commit` / `status` / `guard` 仍可运行。
  - `CODE_COMPASS_GUARD=off` 能绕过所有闸门（exit 0）。
  - 状态文件损坏时给出明确错误而非"假拦截"含糊提示。
  - `product-analysis` 不再产生字面量 `<capability>` 目录。
  - worktree 创建于 `TARGET_DIR/.worktrees/<slug>` 并加入 `.gitignore`。

## What Changes

触及 capability `cli-robustness`：CLI 自身的健壮性与正确性（JSON 读写层、闸门豁免、状态解析、spec 落点、worktree 路径、原子写）。

## Impact

- 模块：`skills/code-compass/code-compass`（核心脚本）
- 命令：`init` / `product-analysis` / `dev` / `commit` / `status` / `guard` 均受影响
- 文档：`guard.md` / `commit/SKILL.md` / `AGENTS.md.harness` 中关于 `CODE_COMPASS_GUARD=off` 的描述已与实现一致（本次仅补齐实现侧）
