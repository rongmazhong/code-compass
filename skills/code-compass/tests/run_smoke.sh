#!/usr/bin/env bash
# cli-modular 回归冒烟（bats 未安装时的等价实现）。
# 与 tests/cli_modular.bats 的 @test 一一对应（R1–R11）。
# 每个用例写成自包含函数，由 check 在独立临时目录内运行，断言也在该目录内执行。
set -uo pipefail

CC="$(cd "$(dirname "$0")/.." && pwd)/code-compass"
pass=0; fail=0

check() { local d="$1"; shift; local t; t="$(mktemp -d)"; cd "$t"; git init -q .; git config user.email t@t.co; git config user.name t; if "$@"; then echo "  ok  $d"; pass=$((pass+1)); else echo "FAIL  $d"; fail=$((fail+1)); fi; cd - >/dev/null; rm -rf "$t"; }

# R1 init 模板（tracks + 新 schema）
r1_init() {
  bash "$CC" init >/dev/null 2>&1
  [ -f .harness/config.json ] \
    && [ "$(jq -r '.tracks|keys|length' .harness/config.json)" -ge 4 ] \
    && [ "$(jq -r 'has("changes")' .harness/state/workflow-state.json)" = true ]
}
check "R1 init tracks+schema" r1_init

# R2 status --all 多变更 + status activate 的 track 感知裁剪
# 注：status 子命令退出码非 0，set -o pipefail 下 "cmd | grep" 会误判，
# 故先捕获输出到变量再 grep（避免管道误伤）。
r2_status() {
  r1_init
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"verified",branch:"",track:"small",vapd_id:"",updated_at:"",completed:[]},b:{stage:"dev",branch:"feat/b",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  local all act
  all="$(bash "$CC" status --all 2>&1)"
  act="$(bash "$CC" status activate 2>&1)"
  printf '%s' "$all" | grep -q a \
    && printf '%s' "$all" | grep -q b \
    && printf '%s' "$act" | grep -q "wiki\|收尾"
}
check "R2 status --all + activate prune" r2_status

# R3 guard 闸门（idea 拦截 / planned 放行）
r3_guard_idea() {
  r1_init
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"idea",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  ! bash "$CC" guard >/dev/null 2>&1
}
check "R3 guard idea blocks" r3_guard_idea

r3_guard_planned() {
  r1_init
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"planned",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  bash "$CC" guard >/dev/null 2>&1
}
check "R3 guard planned passes" r3_guard_planned

# R4 commit 规范 <type>: #{VAPD_ID}#<描述>
r4_commit() {
  r1_init
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"implemented",branch:"",track:"standard",vapd_id:"VR-001",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  echo x > _t && git add _t
  bash "$CC" commit feat 新功能 >/dev/null 2>&1
  [ "$(git log -1 --pretty=%s)" = "feat: #VR-001#新功能" ]
}
check "R4 commit VAPD msg" r4_commit

# R5 product-analysis --append / --force
r5_append_force() {
  r1_init
  printf '问题1\n' | bash "$CC" product-analysis --append >/dev/null 2>&1
  grep -q 问题1 .harness/issues.md \
    && bash "$CC" product-analysis --force c >/dev/null 2>&1 \
    && [ -d .harness/openspec/changes/c ]
}
check "R5 append/force" r5_append_force

# R6 qa 推进至 verified
r6_qa() {
  r1_init
  mkdir -p .harness/openspec/changes/a/specs/core
  printf '# 开发流程\n- 测试：true\n- 静态检查：true\n' > .harness/rules/workflow.md
  echo R > .harness/openspec/changes/a/specs/core/spec.md
  printf -- '- [ ] t\n' > .harness/openspec/changes/a/tasks.md
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"implemented",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  bash "$CC" qa >/dev/null 2>&1
  [ "$(jq -r '.changes.a.stage' .harness/state/workflow-state.json)" = verified ]
}
check "R6 qa advances to verified" r6_qa

# R7 模块可加载（所有 lib 语法 + source 后函数可达）
r7_libs() {
  bash -n "$CC" \
    && for f in "$(cd "$(dirname "$CC")" && pwd)"/lib/*.sh "$(cd "$(dirname "$CC")" && pwd)"/lib/cmds/*.sh; do bash -n "$f" || return 1; done \
    && bash -c "source \"$CC\"; type cmd_init cmd_guard cmd_commit cmd_qa cmd_upgrade >/dev/null 2>&1"
}
check "R7 libs source + commands exposed" r7_libs

# R8 upgrade 刷新老项目 harness 配置（cc-upgrade）
# 注：check 在临时目录内执行 "$@"，故用自包含函数确保断言也在该目录内。
upg_old() {
  bash "$CC" init >/dev/null 2>&1
  jq 'del(.tracks) | . + {mykey:"keep-me"}' .harness/config.json > c.tmp && mv c.tmp .harness/config.json
  jq '.changes.a = {stage:"dev",branch:"feat/a",track:"standard",vapd_id:"",completed:[]}' .harness/state/workflow-state.json > s.tmp && mv s.tmp .harness/state/workflow-state.json
  jq '(.changes[]?) |= del(.updated_at)' .harness/state/workflow-state.json > s.tmp && mv s.tmp .harness/state/workflow-state.json
  echo "# sentinel" > .harness/rules/SENTINEL.md
  bash "$CC" upgrade >/dev/null 2>&1
  [ "$(jq -r 'has("tracks")' .harness/config.json)" = true ] \
   && [ "$(jq -r '.mykey' .harness/config.json)" = keep-me ] \
   && [ "$(jq -r '.tracks|keys|length' .harness/config.json)" -ge 4 ] \
   && [ "$(jq -r '.changes.a.updated_at' .harness/state/workflow-state.json)" != null ] \
   && [ -f .harness/rules/SENTINEL.md ]
}
check "R8 upgrade refreshes old project" upg_old

# R9 upgrade 范围锁定：不碰 rules/、AGENTS.md
upg_scope() {
  bash "$CC" init >/dev/null 2>&1
  jq 'del(.tracks)' .harness/config.json > c.tmp && mv c.tmp .harness/config.json
  echo "# sentinel" > .harness/rules/SENTINEL.md
  # init 把 AGENTS.md 注入项目根目录，记下来用于校验 upgrade 不碰它
  cp AGENTS.md AGENTS.md.bak
  echo "# user-edit" >> AGENTS.md
  bash "$CC" upgrade >/dev/null 2>&1
  [ -f .harness/rules/SENTINEL.md ] \
    && [ -f AGENTS.md ] \
    && grep -q "user-edit" AGENTS.md
}
check "R9 upgrade scope-locked" upg_scope

# R10 upgrade 幂等
upg_idem() {
  bash "$CC" init >/dev/null 2>&1
  bash "$CC" upgrade >/dev/null 2>&1
  bash "$CC" upgrade 2>&1 | grep -q "已是最新"
}
check "R10 upgrade idempotent" upg_idem

# R11 upgrade --self 无 upgrade_source 时跳过
upg_self() {
  bash "$CC" init >/dev/null 2>&1
  bash "$CC" upgrade --self 2>&1 | grep -q "未配置 upgrade_source"
}
check "R11 upgrade --self skip no source" upg_self

echo "----"
echo "PASS=$pass FAIL=$fail"
[ "$fail" -eq 0 ]