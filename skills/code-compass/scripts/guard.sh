#!/usr/bin/env bash
# scripts/guard.sh —— 阶段闸门：idea/product-analysis 非0拦截，planned+ 放行
#
# 直接运行： bash scripts/guard.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_guard "$@"
