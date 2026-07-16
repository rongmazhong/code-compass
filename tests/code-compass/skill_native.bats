#!/usr/bin/env bats
# code-compass skill-native-redesign 回归测试（scripts/ 机械工具层）
# 与 tests/run_smoke.sh 一一对应。bats-core 可用时：
#   bats skills/code-compass/tests/skill_native.bats

SCRIPTS="$(cd "$(dirname "$BATS_TEST_FILENAME")/../.." && pwd)/skills/code-compass/scripts"
cc() { bash "$SCRIPTS/$1.sh" "${@:2}"; }

setup() {
  BATS_TMP="$(mktemp -d)"
  cd "$BATS_TMP"
  git init -q .; git config user.email t@t.co; git config user.name t
}
teardown() { rm -rf "$BATS_TMP"; }

@test "init-harness tracks+schema (idempotent)" {
  cc init-harness; [ "$status" -eq 0 ]
  [ -f .harness/config.json ] && [ -f .harness/state/workflow-state.json ]
  [ "$(jq -r '.tracks|keys|length' .harness/config.json)" -ge 4 ]
  [ "$(jq -r 'has("changes")' .harness/state/workflow-state.json)" = true ]
  cc init-harness; [ "$status" -eq 0 ]
}
@test "status --all lists changes; activate prunes by track" {
  cc init-harness >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"verified",branch:"",track:"small",vapd_id:"",updated_at:"",completed:[]},b:{stage:"dev",branch:"feat/b",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  run cc status --all; [[ "$output" == *"a"* ]] && [[ "$output" == *"b"* ]]
  run cc status activate; [[ "$output" == *"wiki"* ]] || [[ "$output" == *"收尾"* ]]
}
@test "guard blocks idea / allows planned" {
  cc init-harness >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"idea",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  run cc guard; [ "$status" -ne 0 ]
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"planned",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  run cc guard; [ "$status" -eq 0 ]
}
@test "commit builds VAPD-prefixed message" {
  cc init-harness >/dev/null 2>&1
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"implemented",branch:"",track:"standard",vapd_id:"VR-001",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  echo x > _t && git add _t
  cc commit feat "新功能"; [ "$status" -eq 0 ]
  [ "$(git log -1 --pretty=%s)" = "feat: #VR-001#新功能" ]
}
@test "product-analysis --append/--force" {
  cc init-harness >/dev/null 2>&1
  printf '问题1\n' | cc product-analysis --append >/dev/null 2>&1
  [ -f .harness/issues.md ] && grep -q "问题1" .harness/issues.md
  cc product-analysis --force c >/dev/null 2>&1; [ -d .harness/openspec/changes/c ]
}
@test "qa advances to verified" {
  cc init-harness >/dev/null 2>&1
  mkdir -p .harness/openspec/changes/a/specs/core
  printf '# 开发流程\n- 测试：true\n- 静态检查：true\n' > .harness/rules/workflow.md
  echo R > .harness/openspec/changes/a/specs/core/spec.md
  printf -- '- [ ] t\n' > .harness/openspec/changes/a/tasks.md
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"implemented",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  cc qa >/dev/null 2>&1; [ "$(jq -r '.changes.a.stage' .harness/state/workflow-state.json)" = "verified" ]
}
@test "state.sh get/set/set-stage/set-vapd" {
  cc init-harness >/dev/null 2>&1
  cc state ensure z >/dev/null 2>&1; cc state set-stage z dev >/dev/null 2>&1
  [ "$(cc state get z stage)" = "dev" ]
  cc state set-vapd VR-9 >/dev/null 2>&1; [ "$(cc state get z vapd_id)" = "VR-9" ]
}
@test "upgrade adds tracks/updated_at, preserves keys" {
  cc init-harness >/dev/null 2>&1
  jq 'del(.tracks)' .harness/config.json > .harness/config.json.tmp && mv .harness/config.json.tmp .harness/config.json
  jq '. + {mykey:"keep-me"}' .harness/config.json > .harness/config.json.tmp && mv .harness/config.json.tmp .harness/config.json
  jq '.changes.a = {stage:"dev",branch:"feat/a",track:"standard",vapd_id:"",completed:[]}' .harness/state/workflow-state.json > .harness/state/workflow-state.json.tmp && mv .harness/state/workflow-state.json.tmp .harness/state/workflow-state.json
  jq '(.changes[]?) |= del(.updated_at)' .harness/state/workflow-state.json > .harness/state/workflow-state.json.tmp && mv .harness/state/workflow-state.json.tmp .harness/state/workflow-state.json
  echo "# sentinel" > .harness/rules/SENTINEL.md
  cc upgrade >/dev/null 2>&1
  [ "$(jq -r '.tracks|keys|length' .harness/config.json)" -ge 4 ]
  [ "$(jq -r '.mykey' .harness/config.json)" = "keep-me" ]
  [ "$(jq -r '.changes.a.updated_at' .harness/state/workflow-state.json)" != "null" ]
}

# review 多视角链：编排四视角并推进到 reviewed
@test "review runs multi-perspective and advances to reviewed" {
  cc init-harness >/dev/null 2>&1
  mkdir -p .harness/openspec/changes/a/specs/core
  cat > .harness/openspec/changes/a/specs/core/spec.md <<'EOF'
## ADDED Requirements
### Requirement: auth-login
系统 SHALL 提供登录。
#### Scenario: 正常
- **WHEN** 登录
- **THEN** 成功
EOF
  printf -- '- [x] 实现 auth-login\n' > .harness/openspec/changes/a/tasks.md
  echo "def login():" > auth.py && git add auth.py
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"verified",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  cc review >/dev/null 2>&1
  [ "$(jq -r '.changes.a.stage' .harness/state/workflow-state.json)" = "reviewed" ]
}

# review security 命中硬编码密钥时阻断推进
@test "review blocks advance on hardcoded secret" {
  cc init-harness >/dev/null 2>&1
  mkdir -p .harness/openspec/changes/a/specs/core
  echo "## ADDED Requirements" > .harness/openspec/changes/a/specs/core/spec.md
  echo "api_key = \"ABCDEFGHIJKLMNOPQRSTUVWXYZ123456\"" > secret.py && git add secret.py
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"verified",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  ! cc review >/dev/null 2>&1
  [ "$(jq -r '.changes.a.stage' .harness/state/workflow-state.json)" = "verified" ]
}

# review 子脚本可独立运行单视角
@test "review-product.sh runs single perspective" {
  cc init-harness >/dev/null 2>&1
  mkdir -p .harness/openspec/changes/a/specs/core
  echo "## ADDED Requirements" > .harness/openspec/changes/a/specs/core/spec.md
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"verified",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  cc review-product; [ "$status" -eq 0 ]
}

# verify 四维：mapping 缺失时失败
@test "verify fails when requirement lacks test mapping" {
  cc init-harness >/dev/null 2>&1
  mkdir -p .harness/openspec/changes/a/specs/core
  cat > .harness/openspec/changes/a/specs/core/spec.md <<'EOF'
## ADDED Requirements
### Requirement: feat-x
系统 SHALL 做 x。
EOF
  printf -- '- [x] 实现 feat-x\n' > .harness/openspec/changes/a/tasks.md
  printf '# 开发流程\n- 测试：true\n- 静态检查：true\n' > .harness/rules/workflow.md
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"verified",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  ! cc verify >/dev/null 2>&1
}

# verify 四维：mapping 完整且测试绿时通过
@test "verify passes with full mapping and green tests" {
  cc init-harness >/dev/null 2>&1
  mkdir -p .harness/openspec/changes/a/specs/core
  cat > .harness/openspec/changes/a/specs/core/spec.md <<'EOF'
## ADDED Requirements
### Requirement: feat-x
系统 SHALL 做 x。
EOF
  printf -- '- [x] 实现 feat-x\n- Requirement: feat-x → test: tests/x.bats\n' > .harness/openspec/changes/a/tasks.md
  printf '# 开发流程\n- 测试：true\n- 静态检查：true\n' > .harness/rules/workflow.md
  echo "x" > tests_x.bats
  jq -n '{tool:"x",active:"a",changes:{a:{stage:"verified",branch:"",track:"standard",vapd_id:"",updated_at:"",completed:[]}}}' > .harness/state/workflow-state.json
  cc verify >/dev/null 2>&1
}
