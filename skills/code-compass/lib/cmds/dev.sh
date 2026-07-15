# ---------------------------------------------------------------------------
# lib/dev.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- cmd_dev ---
cmd_dev() {
  local force=0
  # 解析 --force 豁免（其余参数视为 slug）
  local pos=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --force) force=1; shift ;;
      -*) warn "未知选项: $1"; shift ;;
      *) pos+=("$1"); shift ;;
    esac
  done
  local slug="${pos[0]:-}"

  if [ -z "$slug" ]; then
    local latest; latest="$(ls -1 "$TARGET_DIR/.harness/openspec/changes" 2>/dev/null | tail -1 || true)"
    [ -z "$latest" ] && die "未找到任何变更，请先运行: code-compass product-analysis <name>"
    slug="$latest"
    warn "未指定变更，自动选择最新一个: $slug"
  fi
  local change_dir="$TARGET_DIR/.harness/openspec/changes/$slug"
  if [ ! -d "$change_dir" ]; then
    if [ "$force" -eq 1 ]; then
      # 强制模式作为逃生舱：尚未运行 product-analysis 时，先脚手架变更工作区再进入 dev
      warn "未找到变更工作区，--force 模式下自动脚手架: $slug"
      mkdir -p "$change_dir/specs/core"
      cp "$CC_ROOT/templates/proposal.md" "$change_dir/proposal.md"
      cp "$CC_ROOT/templates/tasks.md"   "$change_dir/tasks.md"
      cp "$CC_ROOT/templates/spec.md"    "$change_dir/specs/core/spec.md"
    else
      die "变更不存在: $slug（请先运行 code-compass product-analysis $slug）"
    fi
  fi

  # 闸门：禁止在未完成需求分析时进入开发（stage 仍处 idea / product-analysis）
  if [ "$force" -eq 0 ] && [ -f "$TARGET_DIR/.harness/state/workflow-state.json" ]; then
    if [ "${CODE_COMPASS_GUARD:-}" = "off" ]; then
      warn "CODE_COMPASS_GUARD=off：已绕过 dev 闸门（仅调试用）"
    elif ! _can_code; then
      local st; st="$(_state_get stage | tr -d '\n')"
      die "⚠️  闸门拦截：当前阶段 '$st' 尚未生成已确认 spec，禁止进入 dev。
        > 先运行: code-compass product-analysis $slug
        > 如需强制绕过: code-compass dev --force $slug （请在回复中说明豁免理由）"
    fi
    # 存在 state 且 stage>=planned，但变更工作区无 spec 文件，也视为偏离
    if ! ls "$change_dir"/specs/*/spec.md >/dev/null 2>&1; then
      warn "⚠️  变更工作区 $slug 未找到 specs/*/spec.md，疑似未生成 spec。"
      warn "    建议先补完 product-analysis 的 spec，再进入 dev。"
    fi
  fi

  # 创建/复用 git worktree，隔离开发环境
  _setup_worktree "$slug"
  _set_stage "$slug" "dev" "$WT_BRANCH"

  cat <<EOF

✅ 进入开发阶段: .harness/openspec/changes/$slug/
📂 开发隔离于 git worktree:
   - 路径: $WT_PATH
   - 分支: $WT_BRANCH
   （若非 git 仓库则回退到当前目录）

下一步：请 agent 加载 skills/dev/SKILL.md，并在上述 worktree 内工作：
   1. cd 到 worktree 路径，按 spec 开发（spec 位于主仓库 $TARGET_DIR/.harness/openspec/changes/$slug/）
   2. writing-plans   将 spec 拆解为可执行的微任务
   3. TDD             红-绿-重构循环
   4. subagent        逐任务实现
   5. verification     完成前验证
   开发完成后运行:  code-compass worktree prune  （合并/删除分支前清理 worktree）
EOF
}

