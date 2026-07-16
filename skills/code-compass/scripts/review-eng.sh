#!/usr/bin/env bash
# scripts/review-eng.sh —— 单视角审查（cmd_review_eng）
#
# 直接运行： bash scripts/review-eng.sh
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
active="$(_state_active)"
[ -z "$active" ] && { warn "无活跃变更，无法 review-eng"; exit 1; }
cmd_review_eng "$active"
