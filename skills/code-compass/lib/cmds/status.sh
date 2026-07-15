# ---------------------------------------------------------------------------
# lib/status.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _next_step ---
_next_step() {
  local stage="$1"
  case "$stage" in
    idea)             echo "运行 code-compass product-analysis <name> 收敛需求并生成 spec" ;;
    product-analysis) echo "确认 spec 内容，进入 planned 后运行 code-compass dev <name>" ;;
    planned)          echo "已就绪，运行 code-compass dev <name> 开始开发（guard 通过）" ;;
    dev)              echo "开发中：完成后将 stage 推进到 implemented" ;;
    implemented)      echo "运行 qa 验证后进入 verified" ;;
    qa)               echo "QA 进行中，完成后进入 verified" ;;
    verified)         echo "运行 review 后进入 reviewed" ;;
    reviewed)         echo "运行 summary 生成总结文档" ;;
    summary)          echo "流程已收尾，可运行 code-compass wiki 更新文档" ;;
    *)                echo "未知阶段 '$stage'，可手动编辑 workflow-state.json 的 stage 字段" ;;
  esac
}

# --- _print_state_card ---
_print_state_card() {
  local state="$TARGET_DIR/.harness/state/workflow-state.json"
  [ -f "$state" ] || { warn "未检测到 $state，无法输出状态卡"; return 1; }
  local stage spec branch vapd updated
  stage="$(_state_get stage | tr -d '\n')"
  spec="$(_state_get spec | tr -d '\n')"
  branch="$(_state_get branch | tr -d '\n')"
  vapd="$(_state_get vapd_id | tr -d '\n')"
  updated="$(_state_get updated_at | tr -d '\n')"
  local next; next="$(_next_step "$stage")"
  cat <<EOF

📊 项目状态卡
  阶段 stage : $stage
  关联 spec  : ${spec:-（无）}
  开发分支   : ${branch:-（无）}
  VAPD 标识  : ${vapd:-（未设置）}
  最近更新   : $updated
  ➡️  下一步  : $next
EOF
}

# --- cmd_status ---
cmd_status() {
  local mode="${1:-}"
  local state="$TARGET_DIR/.harness/state/workflow-state.json"

  # guard 模式：仅做闸门校验并退出（供 agent 动手前调用）
  if [ "$mode" = "guard" ] || [ "$mode" = "--guard" ]; then
    cmd_guard
    return $?
  fi

  if [ ! -f "$state" ]; then
    warn "未检测到 $state（项目尚未 init）。"
    log "运行 'code-compass init' 初始化后再查看状态。"
    if [ "$mode" = "activate" ] || [ "$mode" = "--activate" ]; then
      log "你也可以立即激活自动化流程：从 IDEA 阶段开始需求分析。"
    fi
    return 1
  fi

  # --all 模式：列出全部变更及其当前阶段
  if [ "$mode" = "all" ] || [ "$mode" = "--all" ]; then
    local active; active="$(_state_active)"
    echo ""
    echo "📋 全部变更状态"
    echo "────────────────────────────"
    local any=0
    while IFS= read -r s; do
      [ -z "$s" ] && continue
      any=1
      local st; st="$(_state_get_for "$s" stage)"
      local mark="  "
      [ "$s" = "$active" ] && mark="▶ "
      printf '  %s%s\t[%s]\n' "$mark" "$s" "${st:-（未知）}"
    done <<< "$(_state_list)"
    [ "$any" -eq 0 ] && echo "  （暂无变更，运行 code-compass product-analysis <name> 创建）"
    echo "────────────────────────────"
    echo "  ▶ 标记为当前活跃变更；查看详情：code-compass status"
    return 0
  fi

  local stage spec branch updated
  stage="$(_state_get stage)"
  spec="$(_state_get spec)"
  branch="$(_state_get branch)"
  updated="$(_state_get updated_at)"

  local chain; chain="$(_stage_chain "$(_state_get track)")"

  # 渲染阶段链进度
  local line="" cur_done=0
  while IFS= read -r s; do
    if [ "$s" = "$stage" ]; then
      line="${line}🔵 ${s}"
      cur_done=1
    elif [ "$cur_done" -eq 0 ]; then
      line="${line}✅ ${s}"
    else
      line="${line}⚪ ${s}"
    fi
    line="${line} → "
  done <<< "$chain"
  line="${line% → }"

  cat <<EOF

📊 code-compass 状态
────────────────────────────
  当前阶段 : ${stage:-（未知）}
  关联 spec : ${spec:-（无）}
  当前分支 : ${branch:-（无）}
  更新时间 : ${updated:-（未知）}
────────────────────────────
  阶段链:
  $line
EOF

   # 偏离提醒：仍处 idea/product-analysis 时，显式警告尚未生成 spec
  case "$stage" in
    idea|product-analysis)
      warn "⚠️  当前阶段 '$stage' 尚未生成已确认 spec：动手写代码前应先走 product-analysis。"
      warn "    运行 'code-compass guard' 校验阶段；用 'code-compass product-analysis <name>' 收敛需求。"
      ;;
  esac

  if [ "$mode" = "activate" ] || [ "$mode" = "--activate" ]; then
    cat <<EOF

🚀 激活自动化流程（参考 develop-workflow-rong 状态机）
   当前阶段: ${stage:-idea}
$(_stage_cmd "${stage:-idea}" "$(_state_get track)" "$(_state_active)")
   提示：agent 加载本步骤对应 skill，执行后将 stage 写入 workflow-state.json，
   下次运行 'code-compass status activate' 即自动从断点续跑。
EOF
  else
    log "运行 'code-compass status activate' 可查看当前阶段应执行的自动化动作。"
    log "运行 'code-compass guard' 可校验当前阶段是否允许动手（偏离会拦截）。"
  fi
}

