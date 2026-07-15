# ---------------------------------------------------------------------------
# lib/worktree.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- cmd_worktree ---
cmd_worktree() {
  local action="${1:-list}"
  case "$action" in
    list)
      if git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        log "当前项目的 git worktree 列表："
        git -C "$TARGET_DIR" worktree list
      else
        warn "目标项目不是 git 仓库"
      fi
      ;;
    prune)
      if git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -C "$TARGET_DIR" worktree prune
        log "已 prune 失效的 worktree 注册信息（如需删除某个 worktree 目录，用: git worktree remove <路径>）"
      else
        warn "目标项目不是 git 仓库"
      fi
      ;;
    *) die "未知动作: $action（可选 list / prune）" ;;
  esac
}

