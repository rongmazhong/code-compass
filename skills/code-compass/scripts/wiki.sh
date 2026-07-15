#!/usr/bin/env bash
# scripts/wiki.sh —— 更新/重建项目 wiki（docs/）
#
# 直接运行： bash scripts/wiki.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_wiki "$@"
