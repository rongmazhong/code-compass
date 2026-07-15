# ---------------------------------------------------------------------------
# lib/vapd.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- cmd_vapd ---
cmd_vapd() {
  local id="${1:-}"
  local state="$TARGET_DIR/.harness/state/workflow-state.json"
  if [ -z "$id" ]; then
    if [ -f "$state" ]; then
      local cur; cur="$(_state_get vapd_id | tr -d '\n')"
      log "当前 VAPD ID: ${cur:-（未设置）}"
    else
      warn "尚未 init，无 state 文件"
    fi
    return 0
  fi
  if ! _is_vapd "$id"; then
    die "VAPD ID 格式不正确：应以 VR（需求）/ VB（缺陷）/ VT（任务）开头，如 VR12345"
  fi
  _set_vapd "$id"
  log "已记录 VAPD ID: $id（写入 .harness/state/workflow-state.json）"
  log "提交时将自动携带：<type>: #$id#<描述>"
}

