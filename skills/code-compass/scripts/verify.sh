#!/usr/bin/env bash
# scripts/verify.sh —— spec 覆盖闸门：核对 Requirement 与 tasks.md
#
# 直接运行： bash scripts/verify.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_verify "$@"
