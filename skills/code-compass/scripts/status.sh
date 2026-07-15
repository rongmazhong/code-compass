#!/usr/bin/env bash
# scripts/status.sh —— 查看/激活工作流状态
#
# 直接运行： bash scripts/status.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_status "$@"
