# ---------------------------------------------------------------------------
# lib/qa.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _wf_cmd ---
_wf_cmd() {
  local label="$1" wf="$TARGET_DIR/.harness/rules/workflow.md"
  [ -f "$wf" ] || return 1
  local line; line="$(grep -E "^[[:space:]]*-[[:space:]]*${label}[：:][[:space:]]*" "$wf" 2>/dev/null | head -1)"
  [ -z "$line" ] && return 1
  local cmd; cmd="$(printf '%s' "$line" | sed -E 's/^[^：:]*[：:][[:space:]]*//')"
  [ -z "$cmd" ] && return 1
  printf '%s' "$cmd" | grep -q '（请补充）\|（未识别' && return 2
  echo "$cmd"
}

# --- cmd_qa ---
cmd_qa() {
  local active; active="$(_state_active)"
  [ -z "$active" ] && { warn "无活跃变更，无法运行 qa"; return 1; }
  log "qa 针对活跃变更: $active"

  local tcmd lcmd have=0
  tcmd="$(_wf_cmd "测试")"; case $? in
    0) have=1 ;;
    2) warn "⚠️  测试命令未配置（rules/workflow.md 为占位），请先补充后再 qa" ;;
  esac
  lcmd="$(_wf_cmd "静态检查")"; case $? in
    0) have=1 ;;
    2) warn "⚠️  静态检查命令未配置（占位），跳过该项" ;;
  esac

  if [ "$have" -eq 0 ]; then
    warn "没有可执行的测试/检查命令，qa 未推进（请先在 rules/workflow.md 填写）"
    return 1
  fi

  local rc=0
  if [ -n "$tcmd" ]; then
    log "▶ 运行测试: $tcmd"
    (cd "$TARGET_DIR" && eval "$tcmd"); rc=$?
    [ $rc -ne 0 ] && { warn "❌ 测试失败（退出 $rc），qa 不推进"; return $rc; }
  fi
  if [ -n "$lcmd" ]; then
    log "▶ 运行静态检查: $lcmd"
    (cd "$TARGET_DIR" && eval "$lcmd"); rc=$?
    [ $rc -ne 0 ] && { warn "❌ 静态检查失败（退出 $rc），qa 不推进"; return $rc; }
  fi

  _set_stage "$active" "verified"
  log "✅ qa 通过，阶段已推进至 verified"
}

# --- cmd_verify ---
cmd_verify() {
  local active; active="$(_state_active)"
  [ -z "$active" ] && { warn "无活跃变更，无法 verify"; return 1; }
  local spec_dir="$TARGET_DIR/.harness/openspec/changes/$active/specs"
  local tasks="$TARGET_DIR/.harness/openspec/changes/$active/tasks.md"
  local n_req=0 n_done=0
  if [ -d "$spec_dir" ]; then
    n_req="$(grep -rhoE '^### Requirement:' "$spec_dir" 2>/dev/null | wc -l | tr -d ' ')"
  fi
  [ -f "$tasks" ] && n_done="$(grep -cE '^[[:space:]]*- \[x\]' "$tasks" 2>/dev/null | tr -d ' ')"
  echo "📋 覆盖度核对（变更: $active）"
  echo "  spec Requirements : $n_req"
  echo "  tasks.md 已勾选   : $n_done"
  if [ "$n_req" -gt "$n_done" ]; then
    warn "⚠️  存在未覆盖需求：$(($n_req - $n_done)) 条未勾选对应任务"
    return 1
  fi
  log "✅ 所有 Requirement 均有对应已勾选任务"
}

# --- cmd_review ---
cmd_review() {
  local active; active="$(_state_active)"
  [ -z "$active" ] && { warn "无活跃变更，无法 review"; return 1; }
  local spec_dir="$TARGET_DIR/.harness/openspec/changes/$active/specs"
  echo ""
  echo "📦 审查包（变更: $active）"
  echo "────────────────────────────"
  echo "▶ 代码变更统计:"
  git -C "$TARGET_DIR" diff --stat 2>/dev/null | sed 's/^/   /'
  echo "▶ spec Requirements:"
  if [ -d "$spec_dir" ]; then
    grep -rhoE '^### Requirement:.*' "$spec_dir" 2>/dev/null | sed 's/^/   /'
  else
    echo "   （无 spec）"
  fi
  echo "▶ 审查清单:"
  echo "   1. 是否对齐 spec 的每一条 Requirement（系统 SHALL ...）"
  echo "   2. Scenario 是否覆盖正常 + 异常路径"
  echo "   3. 是否引入硬编码密钥 / 不安全反序列化 / 条件副作用"
  echo "   4. 测试与 lint 是否全绿（参考 qa 命令）"
  echo "   5. 文档（docs/、commit 信息）是否同步"
  echo "────────────────────────────"
  log "审查包已生成（如需跨模型二审，请 agent 加载 review + codex 执行）"
}

