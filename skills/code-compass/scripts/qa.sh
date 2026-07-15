#!/usr/bin/env bash
# scripts/qa.sh —— 自动化 QA（测试/静态检查），implemented→verified
#
# 直接运行： bash scripts/qa.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_qa "$@"
