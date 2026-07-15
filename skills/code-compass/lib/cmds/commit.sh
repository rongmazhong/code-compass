# ---------------------------------------------------------------------------
# lib/commit.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _is_vapd ---
_is_vapd() {
  case "$1" in
    VR*|VB*|VT*) return 0 ;;
    *) return 1 ;;
  esac
}

# --- cmd_commit ---
cmd_commit() {
  local exempt=0
  local type="" desc=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --exempt) exempt=1; shift ;;
      -*) warn "未知选项: $1"; shift ;;
      *)
        if [ -z "$type" ]; then type="$1"; else desc="$desc $1"; fi
        shift ;;
    esac
  done
  [ -z "$type" ] && die "用法: bash scripts/commit.sh [--exempt] <type> <描述...>（type: feat/fix/docs/refactor/...）"
  case "$type" in
    feat|fix|docs|refactor|test|chore|style|perf|build|ci) ;;
    *) warn "非常规 type: $type（允许 feat/fix/docs/refactor 等）" ;;
  esac
  desc="${desc# }"
  [ -z "$desc" ] && die "请填写提交描述"
  local vapd=""
  local state="$TARGET_DIR/.harness/state/workflow-state.json"
  if [ -f "$state" ]; then
    vapd="$(_state_get vapd_id | tr -d '\n')"
  fi

  # R2: 环境变量豁免 / 提交前阶段校验：禁止在 idea / product-analysis 阶段直接提交
  if [ "${CODE_COMPASS_GUARD:-}" = "off" ]; then
    log "CODE_COMPASS_GUARD=off：已跳过提交期阶段校验（仅调试用）"
  elif [ "$exempt" -eq 0 ] && [ -f "$state" ]; then
    case "$(_state_get stage | tr -d '\n')" in
      idea|product-analysis)
        die "⚠️  提交拦截：当前阶段 '$(_state_get stage | tr -d '\n')' 尚未完成需求分析，不能直接提交实现代码。
          > 先运行: bash scripts/product-analysis.sh <name>
          > 确需绕过: bash scripts/commit.sh --exempt $type $desc" ;;
    esac
  fi

  local msg
  if [ -n "$vapd" ]; then
    msg="$type: #$vapd#$desc"
  else
    msg="$type: $desc"
  fi
  # 优先在当前目录（worktree）提交，否则回退到 TARGET_DIR
  local repo="$TARGET_DIR"
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 && repo="$(pwd)"
  log "提交信息: $msg"
  git -C "$repo" commit -m "$msg"
}

