#!/usr/bin/env bash
# scripts/status.sh —— 查看/激活工作流状态
#
# 机械工具层入口（redesign 后取代原 code-compass 单文件 CLI 的对应子命令）。
# 直接运行： bash scripts/status.sh [args...]
# 子 skill 在方法论散文中指示 agent 调用本脚本完成确定性步骤。
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_status "$@"
