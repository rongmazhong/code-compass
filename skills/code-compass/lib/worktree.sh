# ---------------------------------------------------------------------------
# lib/worktree.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _setup_worktree ---
_setup_worktree() {
  local slug="$1"
  WT_BRANCH="feat/$slug"
  WT_PATH=""
  local wt_root="$TARGET_DIR/.worktrees"
  WT_PATH="$wt_root/$slug"

  # 将 .worktrees/ 加入 .gitignore（幂等），避免 worktree 目录被纳入版本控制
  if [ -f "$TARGET_DIR/.gitignore" ]; then
    grep -qxF ".worktrees/" "$TARGET_DIR/.gitignore" 2>/dev/null || printf '.worktrees/\n' >> "$TARGET_DIR/.gitignore"
  else
    printf '.worktrees/\n' > "$TARGET_DIR/.gitignore"
  fi

  # 非 git 仓库：退回当前目录直接开发
  if ! git -C "$TARGET_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    warn "目标项目不是 git 仓库，跳过 worktree，直接在当前目录开发"
    WT_PATH="$TARGET_DIR"
    return 0
  fi

  # 已存在同名 worktree：直接复用
  if git -C "$TARGET_DIR" worktree list --porcelain 2>/dev/null | grep -q "worktree $WT_PATH"; then
    log "复用已存在的 worktree: $WT_PATH (分支 $WT_BRANCH)"
    return 0
  fi

  mkdir -p "$wt_root"
  # 路径已存在但不是合法 worktree（残留空目录）：先清理，避免 git worktree add 拒绝
  if [ -e "$WT_PATH" ] && ! git -C "$WT_PATH" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    rm -rf "$WT_PATH"
  fi

  if git -C "$TARGET_DIR" worktree add "$WT_PATH" -b "$WT_BRANCH" 2>/dev/null; then
    log "已创建 worktree: $WT_PATH (分支 $WT_BRANCH)"
  elif git -C "$TARGET_DIR" rev-parse --verify "$WT_BRANCH" >/dev/null 2>&1; then
    # 分支已存在：挂到该分支
    if git -C "$TARGET_DIR" worktree add "$WT_PATH" "$WT_BRANCH" 2>/dev/null; then
      log "已挂载已有分支 $WT_BRANCH 到 worktree: $WT_PATH"
    else
      warn "创建 worktree 失败，退回当前目录开发"
      WT_PATH="$TARGET_DIR"
    fi
  else
    warn "创建 worktree 失败，退回当前目录开发"
    WT_PATH="$TARGET_DIR"
  fi
}

