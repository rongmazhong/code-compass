#!/usr/bin/env bats
# code-compass CLI —— 模块化拆分后的回归测试
# 覆盖 cli-modular 拆分的 7 个关键行为，确保拆分后行为与原单文件巨石一致。
#
# 运行（需安装 bats-core）：
#   bats skills/code-compass/tests/cli_modular.bats
# 本环境未预装 bats 时，可用 `bash skills/code-compass/tests/cli_modular.bats.sh` 等价冒烟。

CC="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/code-compass"

setup() {
  BATS_TMP="$(mktemp -d)"
  cd "$BATS_TMP"
  # 轻量 git 仓库，供 commit 测试
  git init -q .
  git config user.email "test@code-compass.local"
  git config user.name "cc-test"
}

teardown() {
  rm -rf "$BATS_TMP"
}

# ---------------------------------------------------------------------------
# R1: init 脚手架模板（tracks + 新 schema，5619dba 修复回归）
# ---------------------------------------------------------------------------
@test "init creates .harness with tracks and new-state schema" {
  run bash "$CC" init
  [ "$status" -eq 0 ]
  [ -f .harness/config.json ]
  [ -f .harness/state/workflow-state.json ]
  run jq -r '.tracks | keys | length' .harness/config.json
  [ "$output" -ge 4 ]
  run jq -r 'has("changes")' .harness/state/workflow-state.json
  [ "$output" = "true" ]
}

# ---------------------------------------------------------------------------
# R2: status --all 多变更 + status activate 的 track 感知裁剪
# ---------------------------------------------------------------------------
@test "status --all lists all changes; activate prunes by track" {
  bash "$CC" init >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"verified",branch:"",track:"small",vapd_id:"",updated_at:"",completed:[]},b:{stage:"dev",branch:"feat/b",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  run bash "$CC" status --all
  [[ "$output" == *"a"* ]]
  [[ "$output" == *"b"* ]]
  # small track 在 verified 后裁剪掉 review，提示收尾/wiki
  run bash "$CC" status activate
  [[ "$output" == *"wiki"* ]] || [[ "$output" == *"收尾"* ]]
}

# ---------------------------------------------------------------------------
# R3: guard 闸门（idea 拦截 / planned 放行）
# ---------------------------------------------------------------------------
@test "guard blocks idea stage and allows planned" {
  bash "$CC" init >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"idea",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  run bash "$CC" guard
  [ "$status" -ne 0 ]
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"planned",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  run bash "$CC" guard
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# R4: commit 规范 <type>: #{VAPD_ID}#<描述> 与 --exempt 豁免
# ---------------------------------------------------------------------------
@test "commit builds VAPD-prefixed message" {
  bash "$CC" init >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"implemented",branch:"",track:"standard",vapd_id:"VR-001",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  echo x > _t && git add _t
  run bash "$CC" commit feat "新功能"
  [ "$status" -eq 0 ]
  run git log -1 --pretty=%s
  [ "$output" = "feat: #VR-001#新功能" ]
}

# ---------------------------------------------------------------------------
# R5: product-analysis --append / --force
# ---------------------------------------------------------------------------
@test "product-analysis --append and --force" {
  bash "$CC" init >/dev/null 2>&1
  printf '问题1\n' | bash "$CC" product-analysis --append >/dev/null 2>&1
  [ -f .harness/issues.md ]
  run grep -c "问题1" .harness/issues.md
  [ "$output" -ge 1 ]
  bash "$CC" product-analysis --force c >/dev/null 2>&1
  [ -d .harness/openspec/changes/c ]
}

# ---------------------------------------------------------------------------
# R6: qa/verify/review 状态机推进
# ---------------------------------------------------------------------------
@test "qa advances stage to verified when checks pass" {
  bash "$CC" init >/dev/null 2>&1
  mkdir -p .harness/openspec/changes/a/specs/core
  printf '# 开发流程\n- 测试：true\n- 静态检查：true\n' > .harness/rules/workflow.md
  echo "R" > .harness/openspec/changes/a/specs/core/spec.md
  printf -- '- [ ] t\n' > .harness/openspec/changes/a/tasks.md
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"implemented",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  run bash "$CC" qa
  [ "$status" -eq 0 ]
  run jq -r '.changes.a.stage' .harness/state/workflow-state.json
  [ "$output" = "verified" ]
}

# ---------------------------------------------------------------------------
# R7: 模块可加载（所有 lib 语法 + source 后函数可达）
# ---------------------------------------------------------------------------
@test "all lib files source without error and expose commands" {
  root="$(cd "$(dirname "$CC")" && pwd)"
  run bash -c "for f in \"$root\"/lib/*.sh \"$root\"/lib/cmds/*.sh; do bash -n \"\$f\" || exit 1; done"
  [ "$status" -eq 0 ]
  run bash -c "source \"$root\"/code-compass; type cmd_init cmd_guard cmd_commit cmd_qa >/dev/null 2>&1"
  [ "$status" -eq 0 ]
}
