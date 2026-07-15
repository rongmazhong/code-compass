# ---------------------------------------------------------------------------
# lib/use.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- cmd_use ---
cmd_use() {
  log "code-compass 已全局安装: $SKILLS_DIR/code-compass"
  if [ ! -d "$SKILLS_DIR/code-compass" ]; then
    warn "未检测到 $SKILLS_DIR/code-compass，请先运行: npx skills add rongmazhong/code-compass"
  fi
  log "可用 skill: $(ls "$CC_ROOT"/skills 2>/dev/null)"

  # 1) 确保当前项目已初始化 harness（需求：未 init 则初始化）
  local did_init=0
  if [ ! -d "$TARGET_DIR/.harness" ]; then
    log "目标项目尚未初始化，先执行 init ..."
    cmd_init
    did_init=1
  else
    log "目标项目已初始化 (.harness 存在)"
  fi

  # 2) 校验并补全 AGENTS.md 路由段（幂等）
  _ensure_agents_md

  # 3) 内联打印项目状态卡（需求：判定项目状态并给出下一步）
  _print_state_card

  cat <<EOF

✅ code-compass 已启用。

本工具不创建任何软链；全局安装位于 $SKILLS_DIR/code-compass。
运行命令请使用完整路径（建议为其配置 alias 或加入 PATH）：
  $CC_ROOT/code-compass init | product-analysis | dev

agent 触发各子 skill：读取 $CC_ROOT/skills/<name>/SKILL.md
各 skill 触发条件见对应 SKILL.md 的 frontmatter description。
EOF
}

