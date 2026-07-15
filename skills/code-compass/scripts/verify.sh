#!/usr/bin/env bash
# scripts/verify.sh —— spec 覆盖闸门：核对 Requirement 与 tasks.md
#
# 机械工具层入口（redesign 后取代原 code-compass 单文件 CLI 的对应子命令）。
# 直接运行： bash scripts/verify.sh [args...]
# 子 skill 在方法论散文中指示 agent 调用本脚本完成确定性步骤。
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_bootstrap.sh"
cmd_verify "$@"
