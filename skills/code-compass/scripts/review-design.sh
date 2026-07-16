#!/usr/bin/env bash
# scripts/review-design.sh —— 单视角审查（cmd_review_design）
#
# 直接运行： bash scripts/review-design.sh
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
active="$(_state_active)"
[ -z "$active" ] && { warn "无活跃变更，无法 review-design"; exit 1; }
cmd_review_design "$active"
