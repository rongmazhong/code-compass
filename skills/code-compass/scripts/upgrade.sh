#!/usr/bin/env bash
# scripts/upgrade.sh —— 刷新已 init 项目的 harness 配置
#
# 直接运行： bash scripts/upgrade.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_upgrade "$@"
