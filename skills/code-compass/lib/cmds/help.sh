# ---------------------------------------------------------------------------
# lib/help.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- cmd_help ---
cmd_help() {
  cat <<EOF
code-compass —— 个人 skill 库（纯 skill + scripts/ 机械工具层）

用法（agent 按意图加载对应子 skill，需要时调 scripts/*.sh）:
  bash scripts/use.sh                     注册并启用本 skill 库
  bash scripts/init-harness.sh            在当前项目初始化 .harness/ 与 AGENTS.md
  bash scripts/product-analysis.sh [name]     柏拉图式发问，确定需求范围并生成 spec
  bash scripts/product-analysis.sh --append "文本"   仅追加澄清/决策到 .harness/issues.md
  bash scripts/product-analysis.sh --force <name>   跳过交互命名，直接建变更工作区
  bash scripts/dev.sh [name]              基于 spec 进行开发实现（自动创建 git worktree）
  bash scripts/worktree.sh [list|prune]   管理开发用 git worktree
  bash scripts/vapd.sh [ID]               记录/查看 VAPD 标识（VR需求/VB缺陷/VT任务）
  bash scripts/commit.sh [--exempt] <type> <描述>  按 <type>: #{VAPD_ID}#<描述> 规范提交（含阶段校验）
  bash scripts/status.sh [activate]       查看当前状态；activate 激活当前阶段自动化流程
  bash scripts/guard.sh                   闸门校验：当前阶段是否允许动手，偏离则拦截
  bash scripts/wiki.sh [topic]            更新/重建项目 wiki（docs/）
  bash scripts/help.sh                    显示本帮助

 环境变量:
   CODE_COMPASS_SKILLS_DIR   agent 技能目录 (默认 ~/.agents/skills)
   CODE_COMPASS_TARGET_DIR   目标项目目录   (默认 当前目录)
EOF
}

