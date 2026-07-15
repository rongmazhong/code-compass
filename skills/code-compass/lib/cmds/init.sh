# ---------------------------------------------------------------------------
# lib/init.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- cmd_init ---
cmd_init() {
  local harness="$TARGET_DIR/.harness"
  local state_dir="$harness/state"
  local rules_dir="$harness/rules"
  mkdir -p "$state_dir" "$rules_dir"

  # 写入 harness 配置
  if [ ! -f "$harness/config.json" ]; then
    cp "$CC_ROOT/harness/config.json" "$harness/config.json"
  fi
  # 单文件决策/澄清记录（合并原 decision-log / 用户偏好 / 决策记录）
  if [ ! -f "$harness/issues.md" ]; then
    cat > "$harness/issues.md" <<'ISSUES'
# code-compass 决策与澄清记录

> 追加式单文件，合并原 decision-log / 用户偏好 / 决策记录。
> 追加命令：code-compass product-analysis --append "你的澄清/决策"
ISSUES
  fi
  # 写入初始工作流状态
  if [ ! -f "$state_dir/workflow-state.json" ]; then
    local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    sed "s/__UPDATED_AT__/$ts/" "$CC_ROOT/harness/workflow-state.json" > "$state_dir/workflow-state.json"
  fi

  # 探测项目并生成 rules/ 规则文件
  _detect_project
  _gen_rules "$rules_dir"
  _gen_guard_rules "$rules_dir"

  # 生成 docs/ 项目 wiki（概览/架构/核心模块/功能与 API + 索引）
  _gen_docs "$TARGET_DIR/docs"

  # 交互式补全 docs/overview.md（仅 TTY，避免非交互调用卡住），并写入 product-analysis 启动提示
  if [ -t 0 ]; then
    _fill_overview "$TARGET_DIR/docs"
  fi

  # openspec 骨架（置于 .harness/openspec 下）
  mkdir -p "$TARGET_DIR/.harness/openspec/specs" "$TARGET_DIR/.harness/openspec/changes"
  if [ ! -f "$TARGET_DIR/.harness/openspec/project.md" ]; then
    cp "$CC_ROOT/harness/openspec/project.md" "$TARGET_DIR/.harness/openspec/project.md"
  fi
  if [ ! -f "$TARGET_DIR/.harness/openspec/README.md" ]; then
    cp "$CC_ROOT/harness/openspec/README.md" "$TARGET_DIR/.harness/openspec/README.md"
  fi

  # 注入 AGENTS.md 指引
  _ensure_agents_md

  log "初始化完成："
  log "  .harness/config.json"
  log "  .harness/state/workflow-state.json"
  log "  .harness/issues.md          (决策/澄清记录，单文件)"
  log "  .harness/rules/ (structure.md workflow.md coding.md)"
  log "  docs/ (wiki: overview/architecture/modules/api + INDEX)"
  log "  .harness/openspec/ (specs/ changes/ project.md)"
  log "  AGENTS.md (已注入 code-compass 路由)"
}

# --- _ensure_agents_md ---
_ensure_agents_md() {
  local agent_md="$TARGET_DIR/AGENTS.md"
  local block; block="$(cat "$CC_ROOT/harness/AGENTS.md.harness")"
  if [ ! -f "$agent_md" ]; then
    printf '%s\n%s\n%s\n' "$MARKER_BEGIN" "$block" "$MARKER_END" > "$agent_md"
    log "已创建 $agent_md 并注入 code-compass 路由段"
  elif grep -q "$MARKER_BEGIN" "$agent_md"; then
    log "$agent_md 已包含 code-compass 路由段"
  else
    printf '\n%s\n%s\n%s\n' "$MARKER_BEGIN" "$block" "$MARKER_END" >> "$agent_md"
    log "已向 $agent_md 追加 code-compass 路由段"
  fi
}

