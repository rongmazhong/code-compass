#!/usr/bin/env bash
# skill-native-redesign 回归冒烟（bats 未安装时的等价实现）。
# 与 tests/skill_native.bats 的 @test 一一对应。
# 验证「移除 CLI 后，scripts/ 机械工具层行为与重构前一致」。
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")/../.." && pwd)/skills/code-compass/scripts"
cc() { bash "$SCRIPTS/$1.sh" "${@:2}"; }
pass=0; fail=0

check() {
  local d="$1"; shift
  local t; t="$(mktemp -d)"
  local rc
  ( cd "$t"; git init -q .; git config user.email t@t.co; git config user.name t
    "$@" )
  rc=$?
  rm -rf "$t"
  if [ "$rc" -eq 0 ]; then echo "  ok  $d"; pass=$((pass+1)); else echo "FAIL  $d"; fail=$((fail+1)); fi
}

# R1 init-harness 脚手架（tracks + 新 schema）+ 幂等
r1_init() {
  cc init-harness >/dev/null 2>&1
  [ -f .harness/config.json ] \
    && [ "$(jq -r '.tracks|keys|length' .harness/config.json)" -ge 4 ] \
    && [ "$(jq -r 'has("changes")' .harness/state/workflow-state.json)" = true ] \
    && cc init-harness >/dev/null 2>&1 \
    && [ -f .harness/config.json ]
}
check "R1 init-harness tracks+schema (idempotent)" r1_init

# R2 status --all 多变更 + activate 的 track 感知裁剪
r2_status() {
  cc init-harness >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"verified",branch:"",track:"small",vapd_id:"",updated_at:"",completed:[]},b:{stage:"dev",branch:"feat/b",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  local all act
  all="$(cc status --all 2>&1)"; act="$(cc status activate 2>&1)"
  printf '%s' "$all" | grep -q a && printf '%s' "$all" | grep -q b \
    && printf '%s' "$act" | grep -q "wiki\|收尾"
}
check "R2 status --all + activate prune" r2_status

# R3 guard 闸门（idea 拦截 / planned 放行）
r3_guard() {
  cc init-harness >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"idea",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  ! cc guard >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"planned",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  cc guard >/dev/null 2>&1
}
check "R3 guard blocks idea / allows planned" r3_guard

# R4 commit 规范 <type>: #{VAPD_ID}#<描述> 与 --exempt
r4_commit() {
  cc init-harness >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"implemented",branch:"",track:"standard",vapd_id:"VR-001",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  echo x > _t && git add _t
  cc commit feat "新功能" >/dev/null 2>&1
  [ "$(git log -1 --pretty=%s)" = "feat: #VR-001#新功能" ]
}
check "R4 commit builds VAPD-prefixed message" r4_commit

# R5 product-analysis --append / --force
r5_pa() {
  cc init-harness >/dev/null 2>&1
  printf '问题1\n' | cc product-analysis --append >/dev/null 2>&1
  [ -f .harness/issues.md ] && grep -q "问题1" .harness/issues.md
  cc product-analysis --force c >/dev/null 2>&1
  [ -d .harness/openspec/changes/c ]
}
check "R5 product-analysis --append/--force" r5_pa

# R6 qa 推进到 verified
r6_qa() {
  cc init-harness >/dev/null 2>&1
  mkdir -p .harness/openspec/changes/a/specs/core
  printf '# 开发流程\n- 测试：true\n- 静态检查：true\n' > .harness/rules/workflow.md
  echo "R" > .harness/openspec/changes/a/specs/core/spec.md
  printf -- '- [ ] t\n' > .harness/openspec/changes/a/tasks.md
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"implemented",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  cc qa >/dev/null 2>&1
  [ "$(jq -r '.changes.a.stage' .harness/state/workflow-state.json)" = "verified" ]
}
check "R6 qa advances to verified" r6_qa

# R7 语法 + 函数可达（lib + scripts + _bootstrap）
r7_syntax() {
  for f in "$SCRIPTS"/*.sh; do
    bash -n "$f" || return 1
  done
  bash -c "source '$SCRIPTS/_common.sh'; type cmd_init cmd_guard cmd_commit cmd_qa cmd_upgrade >/dev/null 2>&1"
}
check "R7 all scripts pass bash -n + expose cmds" r7_syntax

# R8 state.sh 读写
r8_state() {
  cc init-harness >/dev/null 2>&1
  cc state ensure z >/dev/null 2>&1
  cc state set-stage z dev >/dev/null 2>&1
  [ "$(cc state get z stage)" = "dev" ]
  cc state set-vapd VR-9 >/dev/null 2>&1
  [ "$(cc state get z vapd_id)" = "VR-9" ]
}
check "R8 state.sh get/set/set-stage/set-vapd" r8_state

# R9 upgrade 刷新老项目
r9_upgrade() {
  cc init-harness >/dev/null 2>&1
  jq 'del(.tracks)' .harness/config.json > .harness/config.json.tmp && mv .harness/config.json.tmp .harness/config.json
  jq '. + {mykey:"keep-me"}' .harness/config.json > .harness/config.json.tmp && mv .harness/config.json.tmp .harness/config.json
  jq '.changes.a = {stage:"dev",branch:"feat/a",track:"standard",vapd_id:"",completed:[]}' .harness/state/workflow-state.json > .harness/state/workflow-state.json.tmp && mv .harness/state/workflow-state.json.tmp .harness/state/workflow-state.json
  jq '(.changes[]?) |= del(.updated_at)' .harness/state/workflow-state.json > .harness/state/workflow-state.json.tmp && mv .harness/state/workflow-state.json.tmp .harness/state/workflow-state.json
  echo "# sentinel" > .harness/rules/SENTINEL.md
  cc upgrade >/dev/null 2>&1
  [ "$(jq -r '.tracks|keys|length' .harness/config.json)" -ge 4 ] \
    && [ "$(jq -r '.mykey' .harness/config.json)" = "keep-me" ] \
    && [ "$(jq -r '.changes.a.updated_at' .harness/state/workflow-state.json)" != "null" ] \
    && [ -f .harness/rules/SENTINEL.md ]
}
check "R9 upgrade adds tracks/updated_at, preserves keys" r9_upgrade

echo "----"
echo "PASS=$pass FAIL=$fail"
[ "$fail" -eq 0 ]
