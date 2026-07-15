#!/usr/bin/env bash
# scripts/use.sh —— 注册并启用 code-compass 个人 skill 库
#
# 直接运行： bash scripts/use.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_use "$@"
