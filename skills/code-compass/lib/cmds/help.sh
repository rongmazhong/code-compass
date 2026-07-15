# ---------------------------------------------------------------------------
# lib/help.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- cmd_help ---
cmd_help() {
  cat <<EOF
code-compass —— 个人 skill 库 CLI

用法:
  code-compass using-code-compass        注册并启用本 skill 库
  code-compass init                        在当前项目初始化 .harness/ 与 AGENTS.md
  code-compass product-analysis [name]     柏拉图式发问，确定需求范围并生成 spec
  code-compass product-analysis --append "文本"   仅追加澄清/决策到 .harness/issues.md
  code-compass product-analysis --force <name>   跳过交互命名，直接建变更工作区
  code-compass dev|develop [name]          基于 spec 进行开发实现（自动创建 git worktree）
  code-compass worktree [list|prune]       管理开发用 git worktree
  code-compass vapd [ID]                   记录/查看 VAPD 标识（VR需求/VB缺陷/VT任务）
  code-compass commit [--exempt] <type> <描述>  按 <type>: #{VAPD_ID}#<描述> 规范提交（含阶段校验）
  code-compass status [activate]           查看当前状态；activate 激活当前阶段自动化流程
  code-compass guard                       闸门校验：当前阶段是否允许动手，偏离则拦截
  code-compass wiki [topic]                更新/重建项目 wiki（docs/）
  code-compass help                        显示本帮助

 环境变量:
   CODE_COMPASS_SKILLS_DIR   agent 技能目录 (默认 ~/.agents/skills)
   CODE_COMPASS_TARGET_DIR   目标项目目录   (默认 当前目录)
EOF
}

