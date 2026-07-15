#!/usr/bin/env bash
# scripts/vapd.sh —— 记录/查看 VAPD 标识（VR/VB/VT）
#
# 直接运行： bash scripts/vapd.sh [args...]
set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"
cmd_vapd "$@"
