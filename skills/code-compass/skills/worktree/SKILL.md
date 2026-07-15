---
name: worktree
description: >
   管理 code-compass 开发用 git worktree（list / prune）。运行 `code-compass worktree [list|prune]` 或说"查看 worktree / 清理 worktree"时触发。
---

# worktree —— 开发用 git worktree 管理

`dev` 在动手前会为当前变更自动创建（或复用）一个隔离 worktree：
`<父目录>/worktrees/<slug>`（分支 `feat/<slug>`）。本命令用于查看与清理这些 worktree，
避免分支合并后遗留的失效注册。

## 触发条件

- 用户运行 `code-compass worktree list` / `code-compass worktree prune`
- 用户说"看看 worktree"、"清理 worktree"、"合并后收拾一下"
- `dev` 之后、合并分支前后的维护动作

## 用法

### `code-compass worktree`（默认 list）

- 目标项目须是 git 仓库，否则提示"不是 git 仓库"。
- 列出当前项目的 git worktree（`git worktree list`），含各 worktree 路径、所在分支、是否 bare。

### `code-compass worktree prune`

- `git worktree prune`：清理已被删除 worktree 残留的注册信息（不删目录本身）。
- 若需真正删除某个 worktree 目录，用：`git worktree remove <路径>`。
- 目标项目非 git 仓库时提示并跳过。

## 与其它命令的关系

- `dev`：自动创建/复用 `<父目录>/worktrees/<slug>`；本命令是合并后的善后。
- 合并 `feat/<slug>` 入主分支后，建议 `worktree prune` 保持仓库整洁。
