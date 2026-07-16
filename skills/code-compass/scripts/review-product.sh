#!/usr/bin/env bash
# scripts/review-product.sh —— 单视角审查（cmd_review_product）
#
# 直接运行： bash scripts/review-product.sh
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
active="$(_state_active)"
[ -z "$active" ] && { warn "无活跃变更，无法 review-product"; exit 1; }
cmd_review_product "$active"
