#!/usr/bin/env bash
# scripts/_bootstrap.sh —— code-compass skill 库共享引导层
#
# 历史：原 `code-compass` 单文件 CLI 既是调度器又是脚手架。redesign 后 CLI 已移除，
# 能力改为「子 skill（读 SKILL.md 跟方法论）+ scripts/（机械工具层）」。
# 本文件被每个 scripts/*.sh 在开头 source，负责解析 skill 根目录、准备全局变量、
# 载入 lib/ 共享实现，使每个脚本都能独立 `bash scripts/x.sh` 运行。
#
# 被 source 时不分发命令——仅准备环境。具体命令逻辑在 lib/cmds/*.sh 的 cmd_* 函数里。

set -euo pipefail

# 解析脚本真实目录（逐层解析软链，兼容 Linux/macOS）
_resolve_dir() {
  local src="$1" dir link
  while [ -L "$src" ]; do
    dir="$(cd "$(dirname "$src")" && pwd)"
    link="$(readlink "$src")"
    case "$link" in
      /*) src="$link" ;;
      *)  src="$dir/$link" ;;
    esac
  done
  dir="$(cd "$(dirname "$src")" && pwd)"
  printf '%s\n' "$dir"
}

# CC_ROOT = skill 根目录（scripts/ 的上级）
CC_ROOT="$(_resolve_dir "${BASH_SOURCE[0]}")"
CC_ROOT="$(cd "$CC_ROOT/.." && pwd)"
export CC_ROOT

# 解析 HOME（环境可能未设置）
if [ -z "${HOME:-}" ]; then
  HOME="$(getent passwd "$(id -u)" 2>/dev/null | cut -d: -f6)"
  [ -z "$HOME" ] && HOME="$(dscl . -read "/Users/$(id -un)" NFSHomeDirectory 2>/dev/null | awk 'NF>1{print $2}')"
  [ -z "$HOME" ] && HOME=/tmp
fi
: "${HOME:?无法解析 HOME}"

: "${CODE_COMPASS_SKILLS_DIR:=}"
: "${SKILLS_DIR:=$CODE_COMPASS_SKILLS_DIR}"
: "${SKILLS_DIR:=$HOME/.agents/skills}"
: "${CODE_COMPASS_TARGET_DIR:=}"
: "${TARGET_DIR:=$CODE_COMPASS_TARGET_DIR}"
: "${TARGET_DIR:=$(pwd)}"
MARKER_BEGIN="# >>> code-compass >>>"
MARKER_END="# <<< code-compass <<<"
ISSUES_FILE="$TARGET_DIR/.harness/issues.md"
export CC_ROOT TARGET_DIR SKILLS_DIR ISSUES_FILE MARKER_BEGIN MARKER_END

warn() { printf '\033[33m[code-compass]\033[0m %s\n' "$*" >&2; }
log()  { printf '\033[36m[code-compass]\033[0m %s\n' "$*"; }
die()  { printf '\033[31m[code-compass]\033[0m %s\n' "$*" >&2; exit 1; }
export -f warn log die 2>/dev/null || true

# 载入共享实现（lib/ 工具层 + lib/cmds/ 命令实现）
for _f in "$CC_ROOT"/lib/*.sh "$CC_ROOT"/lib/cmds/*.sh; do
  [ -f "$_f" ] && source "$_f"
done
