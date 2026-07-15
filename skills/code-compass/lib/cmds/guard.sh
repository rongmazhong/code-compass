# ---------------------------------------------------------------------------
# lib/guard.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- cmd_guard ---
cmd_guard() {
  # R2: 环境变量豁免开关
  if [ "${CODE_COMPASS_GUARD:-}" = "off" ]; then
    log "CODE_COMPASS_GUARD=off：已绕过闸门（仅调试用）"
    return 0
  fi
  local state="$TARGET_DIR/.harness/state/workflow-state.json"
  if [ ! -f "$state" ]; then
    warn "未检测到 $state（项目尚未 init）。"
    warn "动手前请先运行 'code-compass init' 完成方法论初始化。"
    return 1
  fi
  # R4: 区分"状态文件损坏"与"阶段偏离"
  if ! _json_valid "$state"; then
    warn "⚠️  状态文件损坏：$state 不是合法 JSON，无法校验闸门。"
    warn "    请修复该文件，或删除后重新运行 code-compass init。"
    return 1
  fi
  local stage spec
  stage="$(_state_get stage | tr -d '\n')"
  spec="$(_state_get spec | tr -d '\n')"
  if _can_code; then
    log "✅ 闸门通过：当前阶段 '$stage'，允许进入开发。"
    [ -n "$spec" ] && log "   关联 spec: $spec"
    return 0
  fi
  warn "⚠️  你正在偏离方法论：当前阶段 '$stage' 仍在分析之前，尚未生成已确认 spec。"
  warn "    禁止直接进入编码。请先运行: code-compass product-analysis <name>"
  warn "    确需绕过可用: code-compass dev --force <name>（并说明豁免理由）"
  return 1
}

