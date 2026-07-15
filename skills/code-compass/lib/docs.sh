# ---------------------------------------------------------------------------
# lib/docs.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _gen_docs ---
_gen_docs() {
  local docs_dir="$1"
  mkdir -p "$docs_dir"
  _gen_index "$docs_dir"
  local t
  for t in overview architecture modules api; do
    [ -f "$docs_dir/$t.md" ] && continue
    _write_doc "$docs_dir" "$t"
    log "已生成 $docs_dir/$t.md"
  done
}

# --- _gen_index ---
_gen_index() {
  local docs_dir="$1"
  cat > "$docs_dir/INDEX.md" <<EOF
# 项目 Wiki 索引

> AI agent 先读本索引，再按需深入对应文档。由 code-compass 维护。

## 技术栈速览

- 语言：$PROJ_LANG
- 构建：$PROJ_TECH

## 文档清单

| 文档 | 内容 | 适用场景 |
|------|------|----------|
| docs/overview.md | 项目概览 | 了解"做什么"与目标用户 |
| docs/architecture.md | 架构设计 | 了解"怎么组织"与数据流 |
| docs/modules.md | 核心模块 | 定位模块与职责边界 |
| docs/api.md | 功能与 API | 对外接口 / 契约 |

## 快速理解路径

1. 读 overview.md → 项目目的与用户
2. 读 architecture.md → 分层与数据流
3. 读 modules.md → 核心模块职责
4. 读 api.md → 对外接口

> 更新文档：加载 \`wiki\` 子 skill（运行 \`bash scripts/wiki.sh\`）重建索引；
> 或 \`bash scripts/wiki.sh <overview|architecture|modules|api>\` 重建指定文档。
EOF
}

# --- _write_doc ---
_write_doc() {
  local docs_dir="$1" topic="$2"
  case "$topic" in
    overview)
      cat > "$docs_dir/overview.md" <<EOF
# 项目概览

> 由 code-compass 生成，请补充"项目目的"与"目标用户"。

## 这是什么

__一句话描述本项目解决什么问题、为谁服务。__

## 技术栈

- 语言：$PROJ_LANG
- 构建系统：$PROJ_TECH
- 关键依赖：（待补充）

## 快速开始

- 构建：${PROJ_BUILD:-（待补充）}
- 测试：${PROJ_TEST:-（待补充）}
- 运行：（待补充）

## 相关文档

- 架构设计：architecture.md
- 核心模块：modules.md
- 功能与 API：api.md
EOF
      ;;
    architecture)
      cat > "$docs_dir/architecture.md" <<EOF
# 架构设计

> 由 code-compass 生成，请补充数据流与关键设计决策。

## 技术栈与运行时

- $PROJ_LANG / $PROJ_TECH

## 顶层目录布局

$(_tree)

## 高层结构

\`\`\`
[入口] -> [核心逻辑] -> [外部依赖 / 存储]
\`\`\`

## 关键设计决策

- （待补充：为什么这样分层 / 选型理由 / 关键权衡）
EOF
      ;;
    modules)
      cat > "$docs_dir/modules.md" <<EOF
# 核心模块

> 由 code-compass 探测生成，请补充每个模块的职责与边界。

| 模块/目录 | 职责 | 关键文件 |
|-----------|------|----------|
$(_module_rows)

## 模块关系

- （待补充：模块间依赖与调用关系）
EOF
      ;;
    api)
      cat > "$docs_dir/api.md" <<EOF
# 功能清单及 API 接口

> 由 code-compass 生成。

## 功能清单

- [ ] __功能 A__：描述
- [ ] __功能 B__：描述

## API 接口

| 方法 | 路径 | 说明 | 请求 / 响应 |
|------|------|------|-------------|
| （待补充） | | | |

## 对外契约

- （CLI 子命令 / HTTP 路由 / 库导出，按实际补充）
EOF
      ;;
    *) warn "未知文档主题: $topic（可选 overview/architecture/modules/api）"; return 1 ;;
  esac
}

# --- _tree ---
_tree() {
  local lines=""
  local d
  [ -d "$TARGET_DIR" ] || return 0
  for d in "$TARGET_DIR"/*/; do
    [ -d "$d" ] && lines="${lines}├── $(basename "$d")/"$'\n'
  done
  # 顶层文件
  local f
  for f in "$TARGET_DIR"/*; do
    [ -f "$f" ] && lines="${lines}├── $(basename "$f")"$'\n'
  done
  printf '%s' "$lines"
}

# --- _module_rows ---
_module_rows() {
  local rows=""
  local d
  for d in "$TARGET_DIR"/*/; do
    [ -d "$d" ] || continue
    local name; name="$(basename "$d")"
    local role="（待补充职责）"
    case "$name" in
      src|lib|app) role="源码实现" ;;
      tests|test|spec) role="测试代码" ;;
      docs|doc) role="文档" ;;
      scripts|bin|tools) role="脚本与工具" ;;
      configs|conf|etc|config) role="配置" ;;
      deploy|infra|k8s) role="部署与基础设施" ;;
    esac
    rows="${rows}| $name/ | $role | （待补充） |"$'\n'
  done
  [ -z "$rows" ] && rows="| （未识别到顶层目录） | | |"
  printf '%s' "$rows"
}

