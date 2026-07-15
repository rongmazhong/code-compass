#!/usr/bin/env bash
# scripts/commit.sh —— 按 <type>: #{VAPD_ID}#<描述> 规范提交
#
# 直接运行： bash scripts/commit.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_commit "$@"
