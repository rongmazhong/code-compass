# ---------------------------------------------------------------------------
# lib/detect.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _detect_project ---
_detect_project() {
  PROJ_LANG="未知"
  PROJ_TECH=""
  PROJ_BUILD=""
  PROJ_TEST=""
  PROJ_LINT=""
  PROJ_FMT=""
  PROJ_DIRS=""

  local d
  for d in "$TARGET_DIR"/*/; do
    [ -d "$d" ] && PROJ_DIRS="${PROJ_DIRS:+$PROJ_DIRS, }$(basename "$d")"
  done

  if [ -f "$TARGET_DIR/go.mod" ]; then
    PROJ_LANG="Go"; PROJ_TECH="Go 模块"
    command -v go >/dev/null 2>&1 && PROJ_BUILD="go build ./...  /  go run"
    PROJ_TEST="go test ./..."
    PROJ_LINT="go vet / golangci-lint"
    PROJ_FMT="gofmt / goimports"
  elif [ -f "$TARGET_DIR/Cargo.toml" ]; then
    PROJ_LANG="Rust"; PROJ_TECH="Cargo 项目"
    PROJ_BUILD="cargo build"
    PROJ_TEST="cargo test"
    PROJ_LINT="cargo clippy"
    PROJ_FMT="cargo fmt"
  elif [ -f "$TARGET_DIR/package.json" ]; then
    PROJ_LANG="JavaScript/TypeScript"; PROJ_TECH="Node.js 项目"
    if [ -f "$TARGET_DIR/tsconfig.json" ]; then PROJ_TECH="$PROJ_TECH (TypeScript)"; fi
    local scripts; scripts="$(grep -oE '"(build|test|lint|format|dev|start)"' "$TARGET_DIR/package.json" 2>/dev/null | tr -d '"' | tr '\n' ' ' || true)"
    PROJ_BUILD="npm run build ${scripts:+($scripts)}"
    PROJ_TEST="npm test"
    PROJ_LINT="npm run lint / eslint"
    PROJ_FMT="npm run format / prettier"
    # 探测框架
    grep -q '"next"' "$TARGET_DIR/package.json" && PROJ_TECH="$PROJ_TECH, Next.js"
    grep -q '"react"' "$TARGET_DIR/package.json" && PROJ_TECH="$PROJ_TECH, React"
    true
  elif [ -f "$TARGET_DIR/pyproject.toml" ] || [ -f "$TARGET_DIR/requirements.txt" ]; then
    PROJ_LANG="Python"; PROJ_TECH="Python 项目"
    PROJ_BUILD="pip install -e ."
    PROJ_TEST="pytest"
    PROJ_LINT="ruff / pylint"
    PROJ_FMT="black / ruff format"
  elif [ -f "$TARGET_DIR/pom.xml" ] || [ -f "$TARGET_DIR/build.gradle" ]; then
    PROJ_LANG="Java/Kotlin"; PROJ_TECH="JVM 项目"
    PROJ_BUILD="mvn package / gradle build"
    PROJ_TEST="mvn test / gradle test"
    PROJ_LINT="spotless / checkstyle"
  elif [ -f "$TARGET_DIR/Gemfile" ]; then
    PROJ_LANG="Ruby"; PROJ_TECH="Ruby 项目"
    PROJ_BUILD="bundle exec rake"
    PROJ_TEST="bundle exec rspec"
  elif [ -f "$TARGET_DIR/Makefile" ] || [ -f "$TARGET_DIR/justfile" ] || [ -f "$TARGET_DIR/JUSTFILE" ]; then
    PROJ_LANG="Make"; PROJ_TECH="Make/Just 项目"
    PROJ_BUILD="make"
    PROJ_TEST="make test"
    PROJ_LINT="make lint"
    PROJ_FMT="make fmt"
  elif [ -f "$TARGET_DIR/CMakeLists.txt" ]; then
    PROJ_LANG="C/C++"; PROJ_TECH="CMake 项目"
    PROJ_BUILD="cmake --build build"
    PROJ_TEST="ctest --test-dir build"
  elif ls "$TARGET_DIR"/*.csproj >/dev/null 2>&1 || ls "$TARGET_DIR"/*.sln >/dev/null 2>&1; then
    PROJ_LANG="C#/.NET"; PROJ_TECH="DotNet 项目"
    PROJ_BUILD="dotnet build"
    PROJ_TEST="dotnet test"
    PROJ_FMT="dotnet format"
  elif [ -f "$TARGET_DIR/mix.exs" ]; then
    PROJ_LANG="Elixir"; PROJ_TECH="Elixir 项目"
    PROJ_BUILD="mix compile"
    PROJ_TEST="mix test"
    PROJ_FMT="mix format"
  elif [ -f "$TARGET_DIR/Dockerfile" ]; then
    PROJ_LANG="Docker/容器"; PROJ_TECH="容器化项目"
    PROJ_BUILD="docker build ."
  elif ls "$TARGET_DIR"/*.sh >/dev/null 2>&1 || grep -rlq '^#!.*sh$' "$TARGET_DIR"/* >/dev/null 2>&1; then
    PROJ_LANG="Shell"; PROJ_TECH="Shell 脚本"
    PROJ_LINT="shellcheck（可选）"
  fi

  if [ -z "$PROJ_TECH" ]; then
    PROJ_TECH="（未在根目录识别到已知构建系统）"
  elif [ "$PROJ_LANG" = "未知" ]; then
    # 技术栈信号命中但语言未归类时，仍给出可读标签
    PROJ_LANG="$PROJ_TECH"
  fi
  # 完全未识别：语言字段显式标注，避免静默“未知”
  [ "$PROJ_LANG" = "未知" ] && PROJ_LANG="未识别（请手动填写）"
  return 0
}

# --- _gen_rules ---
_gen_rules() {
  local rules_dir="$1"

  # 1) 项目工程结构定义
  if [ ! -f "$rules_dir/structure.md" ]; then
    cat > "$rules_dir/structure.md" <<EOF
# 项目工程结构定义

> 由 \`code-compass init\` 探测生成，请按需补充与修正。

## 识别到的技术栈

- 语言：$PROJ_LANG
- 构建系统：$PROJ_TECH
- 顶层目录：${PROJ_DIRS:-（无）}

## 目录职责（推断）

| 目录 | 职责 |
|------|------|
$(_dir_roles)

## 约定

- 源码放置：根据上述目录职责统一管理
- 测试与源码同仓，按对应测试框架组织
- 文档、配置、脚本各自归位，避免散落根目录
EOF
    log "已生成 $rules_dir/structure.md"
  else
    warn "$rules_dir/structure.md 已存在，跳过"
  fi

  # 2) 开发流程
  if [ ! -f "$rules_dir/workflow.md" ]; then
    cat > "$rules_dir/workflow.md" <<EOF
# 开发流程

> 由 \`code-compass init\` 生成，结合 code-compass 方法论。

## 标准工作流（code-compass 驱动）

\`\`\`
idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary
\`\`\`

1. **product-analysis**：运行 \`code-compass product-analysis <name>\`，柏拉图式发问确定需求范围，
    产出 \`.harness/openspec/changes/<slug>/{proposal.md,tasks.md,specs/}\`。
2. **dev**：运行 \`code-compass dev <name>\`，按 spec 进行
   计划拆解 → TDD（红-绿-重构）→ 子代理实现 → 验证。
3. 每阶段切换都更新 \`.harness/state/workflow-state.json\`，中断可断点续跑。

## 构建 / 测试 / 检查命令（探测所得）

- 构建：${PROJ_BUILD:-（未识别，请补充）}
- 测试：${PROJ_TEST:-（未识别，请补充）}
- 静态检查：${PROJ_LINT:-（未识别，请补充）}
- 格式化：${PROJ_FMT:-（未识别，请补充）}

## 分支与提交

- 每个变更建议独立分支，命名与 \`.harness/openspec/changes/<slug>\` 对应
- 提交信息清晰描述"为什么"，而非仅"改了什么"
EOF
    log "已生成 $rules_dir/workflow.md"
  else
    warn "$rules_dir/workflow.md 已存在，跳过"
  fi

  # 3) 编码约束
  if [ ! -f "$rules_dir/coding.md" ]; then
    cat > "$rules_dir/coding.md" <<EOF
# 编码约束

> 由 \`code-compass init\` 探测生成，按技术栈裁剪。

## 通用原则

- 先理解问题再写代码；新增功能先写失败测试（TDD）
- 单一职责，函数/模块小而专注
- 错误信息要可操作，禁止静默吞掉异常
- 不引入未经确认的外部依赖；新增依赖前确认项目已在使用
- 不提交密钥、token 等敏感信息

## 语言相关约束（$PROJ_LANG）

$(_coding_rules)

## 风格

- 格式化工具：${PROJ_FMT:-（未识别）}
- 静态检查：${PROJ_LINT:-（未识别）}
- 命名、注释遵循社区主流约定（变量/函数小驼峰或 snake_case，类型/类大驼峰）
EOF
    log "已生成 $rules_dir/coding.md"
  else
    warn "$rules_dir/coding.md 已存在，跳过"
  fi
}

# --- _dir_roles ---
_dir_roles() {
  local rows=""
  _has src lib app      && rows="${rows}| src/ lib/ app/ | 源码实现 |"$'\n'
  _has tests test spec  && rows="${rows}| tests/ test/ spec/ | 测试代码 |"$'\n'
  _has docs doc         && rows="${rows}| docs/ doc/ | 文档 |"$'\n'
  _has scripts bin tools && rows="${rows}| scripts/ bin/ tools/ | 脚本与工具 |"$'\n'
  _has configs conf etc config && rows="${rows}| configs/ conf/ etc/ config/ | 配置 |"$'\n'
  _has deploy infra k8s && rows="${rows}| deploy/ infra/ k8s/ | 部署与基础设施 |"$'\n'
  [ -z "$rows" ] && rows="| （未识别到已知目录，请手动补充） | |"
  printf '%s' "$rows"
}

# --- _has ---
_has() {
  local want
  local dirs="${PROJ_DIRS// /}"
  for want in "$@"; do
    case ",$dirs," in *",$want,"*) return 0 ;; esac
  done
  return 1
}

# --- _coding_rules ---
_coding_rules() {
  case "$PROJ_LANG" in
    Go) cat <<'GO'
- 使用 \`gofmt\` 格式化，导出标识符写注释
- 错误处理显式返回，不忽略 error
- 包名简洁小写，避免下划线
GO
      ;;
    Rust) cat <<'RS'
- 优先 \`cargo fmt\` / \`cargo clippy\`
- 用 \`Result\` 表达可失败，避免 panic 于库代码
- 模块与 trait 组织清晰，避免过大 impl 块
RS
      ;;
    JavaScript/TypeScript) cat <<'JS'
- TypeScript 优先显式类型，避免 \`any\`
- 组件/函数单一职责，遵循项目既有框架约定
- 优先已有库（React/Next 等），不重复造轮子
JS
      ;;
    Python) cat <<'PY'
- 遵循 PEP 8，用 black/ruff 格式化
- 类型注解优先（函数签名标注类型）
- 用虚拟环境隔离依赖，依赖写入 pyproject/requirements
PY
      ;;
    *) echo "- （未识别语言，请补充对应约定）" ;;
  esac
}

# --- _gen_guard_rules ---
_gen_guard_rules() {
  local rules_dir="$1"
  if [ -f "$rules_dir/guard.md" ]; then
    warn "$rules_dir/guard.md 已存在，跳过"
    return 0
  fi
  cat > "$rules_dir/guard.md" <<'EOF'
# 方法论强制契约（guard）

> 由 `code-compass init` 生成。本文件把「方法论优先」从软建议硬化为 agent 必须遵循的约束。

## 1. 硬默认：先分析后开发

任何代码改动意图，默认先走 `product-analysis → planned → dev` 阶段机：

```
idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary
```

- `stage` 仍在 `idea` / `product-analysis` = 尚未确认 spec，**禁止进入编码**。
- 动手前先跑 `code-compass guard`（或 `code-compass status --guard`）做闸门校验。

## 2. 触发词 → 必调 skill

| 意图 / 触发词 | 必调 skill |
|---------------|-----------|
| 新功能 / 做客户端 / 加能力 / 实现 X / 需求 | `product-analysis` |
| 改需求 / 调范围 / 设计一下 / 出方案 | `product-analysis` |
| 按 spec 实现 / 开始开发 / 进入开发 | `dev` |
| 提交 / commit | `commit` |
| 查看进度 / 继续流程 | `status` / `status activate` |
| 我要动手 / 是否可编码 | `guard` |

检测到代码改动意图且尚无 spec 时，**优先调 `product-analysis`**，而非直接编辑。

## 3. 「继续 / 直接做」闸门

`stage` 仍处 `idea` / `product-analysis` 时，用户说「继续 / 直接做 / 做吧」等，
agent 不得直接进入编码；先产出 spec 骨架或澄清清单，再继续。

## 4. 偏离提醒

准备写代码而 `state` 仍处 `idea` / `product-analysis`，`code-compass guard` 会输出黄色提醒
并以非 0 退出（视为偏离）。agent 应停下先走 `product-analysis`，或显式豁免并说明理由。

## 5. 豁免机制

- `code-compass dev --force`：强制进入开发。
- `code-compass commit --exempt <type> <描述>`：跳过提交期阶段校验。
- 环境变量 `CODE_COMPASS_GUARD=off`：关闭全部闸门（仅调试用）。
EOF
  log "已生成 $rules_dir/guard.md"
}

# --- _fill_overview ---
_fill_overview() {
  local docs_dir="$1"
  [ -f "$docs_dir/overview.md" ] || return 0
  log "init 将引导补全 docs/overview.md（并写入「下一步运行 product-analysis」启动提示）"
  local purpose tech user scope
  read -r -p "项目是做什么的（一句话）: " purpose
  read -r -p "技术栈（如 Node/React，可留空用探测值）: " tech
  read -r -p "目标用户是谁: " user
  read -r -p "本次范围 / 目标（可留空）: " scope
  [ -z "$tech" ] && tech="$PROJ_TECH"
  cat > "$docs_dir/overview.md" <<EOF
# 项目概览

> 由 code-compass init 引导生成。

## 这是什么

${purpose:-（待补充）}

## 目标用户

${user:-（待补充）}

## 技术栈

- 语言：$PROJ_LANG
- 构建系统：${tech:-（待补充）}
- 关键依赖：（待补充）

## 范围 / 目标

${scope:-（待补充）}

## 快速开始

- 构建：${PROJ_BUILD:-（待补充）}
- 测试：${PROJ_TEST:-（待补充）}
- 运行：（待补充）

## ⏭️ 下一步

代码改动默认先走方法论：**运行 \`code-compass product-analysis <name>\`** 收敛需求、生成 spec，
再 \`code-compass dev <name>\` 实现。直接用 \`code-compass guard\` 校验阶段是否可动手。

## 相关文档

- 架构设计：architecture.md
- 核心模块：modules.md
- 功能与 API：api.md
EOF
  log "已补全 docs/overview.md 并写入「下一步：product-analysis」启动提示"
}

