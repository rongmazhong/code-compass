#!/usr/bin/env bash
# scripts/product-analysis.sh —— 柏拉图式发问收敛需求并生成 spec 工作区
#
# 直接运行： bash scripts/product-analysis.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_product_analysis "$@"
