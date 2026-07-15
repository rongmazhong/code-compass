#!/usr/bin/env bash
# scripts/dev.sh —— 基于 spec 的开发实现（建 git worktree 隔离）
#
# 直接运行： bash scripts/dev.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_dev "$@"
