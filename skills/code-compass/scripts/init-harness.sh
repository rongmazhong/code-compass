#!/usr/bin/env bash
# scripts/init-harness.sh —— 在当前项目初始化 .harness/ + docs/ + AGENTS 路由
#
# 直接运行： bash scripts/init-harness.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_init "$@"
