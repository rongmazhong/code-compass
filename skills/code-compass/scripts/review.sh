#!/usr/bin/env bash
# scripts/review.sh —— 生成代码审查包（diff/Requirement/清单）
#
# 直接运行： bash scripts/review.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_review "$@"
