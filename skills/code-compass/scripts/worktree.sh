#!/usr/bin/env bash
# scripts/worktree.sh —— 管理开发用 git worktree（list/prune）
#
# 直接运行： bash scripts/worktree.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_worktree "$@"
