# ---------------------------------------------------------------------------
# lib/product-analysis.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _append_issue ---
_append_issue() {
  local slug="$1"; shift
  local text="$*"
  [ -z "$text" ] && text="$(cat)"   # 允许从 STDIN 读取
  [ -z "$text" ] && { warn "无内容可追加到 issues.md"; return 1; }
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  {
    [ -f "$ISSUES_FILE" ] || printf '# code-compass 决策与澄清记录\n\n> 追加式单文件，合并原 decision-log / 用户偏好 / 决策记录。\n'
    printf -- '- [%s] (%s) %s\n' "$ts" "$slug" "$text"
  } >> "$ISSUES_FILE"
  log "已追加到 .harness/issues.md: ($slug) ${text:0:60}"
}

# --- cmd_product_analysis ---
cmd_product_analysis() {
  local name="" vapd="" track="" append="" force=0 rest=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --vapd) vapd="${2:-}"; shift 2 ;;
      --vapd=*) vapd="${1#--vapd=}"; shift ;;
      --track) track="${2:-}"; shift 2 ;;
      --track=*) track="${1#--track=}"; shift ;;
      --append) append=1; shift ;;
      --force) force=1; shift ;;
      -*) warn "未知选项: $1"; shift ;;
      *) [ -z "$name" ] && name="$1" || rest+=("$1"); shift ;;
    esac
  done

  # R2：仅追加一条澄清/决策到 issues.md，不重建 spec
  if [ "$append" = 1 ]; then
    local slug text
    if [ ${#rest[@]} -gt 0 ]; then
      slug="$name"; text="${rest[*]}"          # 形式：--append <slug> "文本"
    else
      slug="$(_state_active)"; [ -z "$slug" ] && slug="global"
      text="$name"                             # 形式：--append "文本"
    fi
    [ -z "$text" ] && text="$(cat)"           # 形式：--append（从 STDIN 读）
    [ -z "$text" ] && die "请提供澄清/决策文本，或使用形式：code-compass product-analysis --append \"文本\""
    _append_issue "$slug" "$text"
    return $?
  fi

  if [ "$force" = 0 ]; then
    [ -z "$name" ] && read -r -p "请输入本次变更名称 (kebab-case): " name
  fi
  [ -z "$name" ] && die "变更名称不能为空（--force 模式下需显式提供名称）"
  local slug; slug="$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')"
  [ -z "$slug" ] && die "无法从 '$name' 生成合法 slug"

  # 校验 track（档位）
  local valid_tracks="research small standard standard+ refactor"
  if [ -n "$track" ]; then
    case " $valid_tracks " in
      *" $track "*) ;;
      *) die "未知 track（档位）: '$track'，可选: $valid_tracks" ;;
    esac
  else
    track="standard"
  fi

  local change_dir="$TARGET_DIR/.harness/openspec/changes/$slug"
  mkdir -p "$change_dir/specs/core"

  cp "$CC_ROOT/templates/proposal.md" "$change_dir/proposal.md"
  cp "$CC_ROOT/templates/tasks.md"   "$change_dir/tasks.md"
  cp "$CC_ROOT/templates/spec.md"    "$change_dir/specs/core/spec.md"

  # 更新工作流状态
  _set_stage "$slug" "product-analysis"
  _set_track "$track" "$slug"

  # 记录 VAPD 标识（若显式给定）
  if [ -n "$vapd" ]; then
    if ! _is_vapd "$vapd"; then
      die "VAPD ID 格式不正确：应以 VR（需求）/ VB（缺陷）/ VT（任务）开头，如 VR12345"
    fi
    _set_vapd "$vapd"
    log "已记录 VAPD ID: $vapd"
  fi

  cat <<EOF

✅ 已创建变更工作区: .harness/openspec/changes/$slug/
   - proposal.md              (Why：意图/档位/决策)
   - tasks.md                 (实施计划，步骤 8 填充)
   - specs/core/spec.md       (spec 模板，步骤 6 填写)

下一步：请 agent 加载 skills/product-analysis/SKILL.md，按"八步流程"推进：
   1.需求诊断 → 2.并行探索 → 3.澄清发问 → 4.对抗验证+方案
   → 5.展示设计 → 6.生成 spec → 7.spec 自检对抗 → 8.交接计划
   完成后运行:  code-compass dev $slug
EOF
}

