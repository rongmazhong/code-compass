# ---------------------------------------------------------------------------
# lib/stages.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _track_stages ---
_track_stages() {
  local track="${1:-standard}" cfg="$TARGET_DIR/.harness/config.json"
  [ -f "$cfg" ] || cfg="$CC_ROOT/harness/config.json"
  local stages=""
  if command -v jq >/dev/null 2>&1; then
    stages="$(jq -r --arg t "$track" 'if (.tracks // {})[$t] then (.tracks[$t][]? // empty) else empty end' "$cfg" 2>/dev/null)"
  fi
  if [ -z "$stages" ] && command -v python3 >/dev/null 2>&1; then
    stages="$(python3 - "$cfg" "$track" <<'PY'
import json, sys
cfg, t = sys.argv[1], sys.argv[2]
try:
    d = json.load(open(cfg))
    arr = d.get("tracks", {}).get(t)
    if arr:
        print("\n".join(arr))
except Exception:
    pass
PY
)"
  fi
  # track 无定义或为空 -> 回退完整 stages
  if [ -z "$stages" ]; then
    if command -v jq >/dev/null 2>&1; then
      stages="$(jq -r '.stages[]? // empty' "$cfg" 2>/dev/null)"
    elif command -v python3 >/dev/null 2>&1; then
      stages="$(python3 - "$cfg" <<'PY'
import json, sys
try:
    print("\n".join(json.load(open(sys.argv[1])).get("stages", [])))
except Exception:
    pass
PY
)"
    fi
    [ -z "$stages" ] && stages=$'idea\nproduct-analysis\nplanned\ndev\nimplemented\nqa\nverified\nreviewed\nsummary'
  fi
  printf '%s\n' "$stages"
}

# --- _stage_chain ---
_stage_chain() {
  local track="${1:-}" cfg="$TARGET_DIR/.harness/config.json"
  [ -f "$cfg" ] || cfg="$CC_ROOT/harness/config.json"
  local stages=""
  if [ -n "$track" ]; then
    stages="$(_track_stages "$track")"
  fi
  if [ -z "$stages" ]; then
    if command -v jq >/dev/null 2>&1; then
      stages="$(jq -r '.stages[]? // empty' "$cfg" 2>/dev/null)"
    fi
    if [ -z "$stages" ] && command -v python3 >/dev/null 2>&1; then
      stages="$(python3 - "$cfg" <<'PY'
import json, sys
try:
    print("\n".join(json.load(open(sys.argv[1])).get("stages", [])))
except Exception:
    pass
PY
)"
    fi
    [ -z "$stages" ] && stages=$'idea\nproduct-analysis\nplanned\ndev\nimplemented\nqa\nverified\nreviewed\nsummary'
  fi
  printf '%s\n' "$stages"
}

# --- _next_stage_in_track ---
_next_stage_in_track() {
  local st="$1" track="${2:-standard}" chain; chain="$(_track_stages "$track")"
  local found=0
  while IFS= read -r s; do
    [ "$found" -eq 1 ] && { echo "$s"; return; }
    [ "$s" = "$st" ] && found=1
  done <<< "$chain"
}

# --- _stage_cmd ---
_stage_cmd() {
  local st="$1" track="${2:-standard}" slug="${3:-<slug>}"
  local pair
  case "$st" in
    idea)              pair="product-analysis|code-compass product-analysis <name>" ;;
    product-analysis)  pair="planned|code-compass status   # 确认 spec 就绪" ;;
    planned)           pair="dev|code-compass dev $slug" ;;
    dev|implemented)   pair="verified|code-compass qa" ;;
    qa)                pair="verified|code-compass verify" ;;
    verified)          pair="reviewed|code-compass review" ;;
    reviewed)          pair="summary|code-compass wiki" ;;
    summary)           echo "# 流程已收尾，可运行 code-compass wiki 更新文档"; return ;;
    *)                 echo "# 未知阶段 '$st'"; return ;;
  esac
  local target="${pair%%|*}" cmd="${pair#*|}"
  # R2：目标阶段不在当前 track 中则顺延到 track 里实际存在的下一阶段命令
  if ! printf '%s\n' "$(_track_stages "$track")" | grep -qx "$target"; then
    local nx; nx="$(_next_stage_in_track "$st" "$track")"
    if [ -n "$nx" ]; then _stage_cmd "$nx" "$track" "$slug"; return; fi
  fi
  echo "$cmd"
}

# --- _stage_action ---
_stage_action() {
  local st="$1"
  case "$st" in
    idea)
      cat <<'ACT'
  ▶ 下一步：运行 `code-compass product-analysis <name>` 进入需求分析。
  ▶ agent 应加载 skills/product-analysis/SKILL.md，按柏拉图式发问收敛需求范围。
ACT
      ;;
    product-analysis)
      cat <<'ACT'
  ▶ 当前：需求分析进行中。agent 应继续加载 skills/product-analysis/SKILL.md，
    将对话结论写入 .harness/openspec/changes/<slug>/{proposal.md,specs/,tasks.md}，
    完成后把 stage 推进到 planned，再运行 `code-compass dev <slug>`。
ACT
      ;;
    planned)
      cat <<'ACT'
  ▶ 下一步：运行 `code-compass dev <slug>` 进入计划拆解与实现。
  ▶ 参考 develop-workflow-rong 的 PLANNED→DEVELOPING 编排（writing-plans → TDD → 子代理）。
ACT
      ;;
    dev)
      cat <<'ACT'
  ▶ 当前：开发进行中。agent 应加载 skills/dev/SKILL.md，按
    计划拆解 → TDD（红-绿-重构）→ 子代理逐任务实现 → 验证 推进，
    完成后把 stage 推进到 implemented。
ACT
      ;;
    implemented)
      cat <<'ACT'
  ▶ 下一步：进入 QA。参考 develop-workflow-rong 的 IMPLEMENTED 阶段，
    用 agent-browser 做端到端测试（页面加载 / 核心流程 / 响应式 / 错误边界），
    修复后把 stage 推进到 qa。
ACT
      ;;
    qa)
      cat <<'ACT'
  ▶ 下一步：QA 验证。参考 develop-workflow-rong 的 QA_PASSED 阶段，
    运行测试套件 + lint + 类型检查，确认修复到位后推进到 verified。
ACT
      ;;
    verified)
      cat <<'ACT'
  ▶ 下一步：代码审查。参考 develop-workflow-rong 的 VERIFIED 阶段，
    加载 requesting-code-review 审查代码是否符合 spec，推进到 reviewed。
ACT
      ;;
    reviewed)
      cat <<'ACT'
  ▶ 下一步：架构与跨模型二审。参考 develop-workflow-rong 的 REVIEWED 阶段，
    加载 review + codex，完成后推进到 summary。
ACT
      ;;
    summary)
      cat <<'ACT'
  ▶ 下一步：总结。参考 code-compass 的 SUMMARY 阶段，
    生成总结文档（变更回顾 / 成果 / 后续），并更新 .harness/state/workflow-state.json。
ACT
      ;;
    *)
      cat <<ACT
  ▶ 未知阶段 "$st"，可手动编辑 .harness/state/workflow-state.json 的 stage 字段回到已知阶段。
ACT
      ;;
  esac
}

# --- _can_code ---
_can_code() {
  local state="$TARGET_DIR/.harness/state/workflow-state.json"
  [ -f "$state" ] || return 2
  if ! _json_valid "$state"; then
    return 3
  fi
  local stage; stage="$(_state_get stage | tr -d '\n')"
  # idea / product-analysis 一律拦截（尚未生成 spec）
  case "$stage" in
    idea|product-analysis) return 1 ;;
  esac
  # 其余阶段：须在“当前 track 的阶段集合”内方为合法
  local track; track="$(_state_get track | tr -d '\n')"
  local chain; chain="$(_track_stages "${track:-standard}")"
  local s
  while IFS= read -r s; do
    [ "$s" = "$stage" ] && return 0
  done <<< "$chain"
  return 1
}

