#!/usr/bin/env bash
# scripts/state.sh —— workflow-state.json 读写工具（机械工具层）
#
# 取代原 code-compass 内部状态读写；可被子 skill 或终端用户直接调用。
# 子命令：
#   active                 打印当前活跃 change 的 slug
#   list                   列出所有 change 的 slug（每行一个）
#   get [slug] [field]     读取字段值（slug 缺省取活跃；field 缺省 stage）
#   set <slug> <field> <v> 写入字段值
#   set-stage <slug> <stg> [branch]  写阶段并维护 completed（去重）
#   set-vapd <id>          写 VAPD 标识到活跃 change
#   ensure <slug>          确保 change 存在（缺省 stage=idea）

set -euo pipefail
_src="${BASH_SOURCE[0]}"
_dir="$(cd "$(dirname "$_src")" && pwd)"
source "$_dir/_common.sh"

cmd="${1:-get}"; shift || true
case "$cmd" in
  active)      _state_active ;;
  list)        _state_list ;;
  get)
    slug="${1:-}"; field="${2:-stage}"
    if [ -z "$slug" ]; then slug="$(_state_active)"; fi
    if [ -z "$slug" ]; then die "无活跃 change，请指定 slug"; fi
    _state_get_for "$slug" "$field"
    ;;
  set)
    slug="${1:-}"; field="${2:-}"; val="${3:-}"
    [ -z "$slug" ] && die "用法: state.sh set <slug> <field> <value>"
    _state_set "$slug" "$field" "$val"
    ;;
  set-stage)
    slug="${1:-}"; stg="${2:-}"; branch="${3:-}"
    [ -z "$slug" ] && die "用法: state.sh set-stage <slug> <stage> [branch]"
    _set_stage "$slug" "$stg" "$branch"
    ;;
  set-vapd)
    id="${1:-}"; [ -z "$id" ] && die "用法: state.sh set-vapd <VR/VB/VT id>"
    _set_vapd "$id"
    ;;
  ensure)
    slug="${1:-}"; [ -z "$slug" ] && die "用法: state.sh ensure <slug>"
    _state_ensure "$slug"
    ;;
  *) warn "未知子命令: $cmd"; exit 1 ;;
esac
