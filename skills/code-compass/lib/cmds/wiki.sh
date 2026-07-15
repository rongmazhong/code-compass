# ---------------------------------------------------------------------------
# lib/wiki.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- cmd_wiki ---
cmd_wiki() {
  local topic="${1:-}"
  local docs_dir="$TARGET_DIR/docs"
  mkdir -p "$docs_dir"

  _detect_project

  if [ -n "$topic" ]; then
    case "$topic" in
      overview|architecture|modules|api)
        _write_doc "$docs_dir" "$topic"
        _gen_index "$docs_dir"
        log "已重建 docs/$topic.md 与 docs/INDEX.md"
        cat <<EOF

✅ docs/$topic.md 已重建（脚手架）。请 agent 阅读当前代码后补全内容：
   - 读取相关源码，填充概览/架构/模块/API 的实际信息
   - 完成后 INDEX.md 已同步
EOF
        ;;
      index)
        _gen_index "$docs_dir"
        log "已重建 docs/INDEX.md"
        ;;
      *) die "未知文档主题: $topic（可选 overview/architecture/modules/api/index）" ;;
    esac
    return 0
  fi

  # 无参数：重建索引，缺失文档补建，已存在则提示
  _gen_index "$docs_dir"
  local t missing=0
  for t in overview architecture modules api; do
    if [ ! -f "$docs_dir/$t.md" ]; then
      _write_doc "$docs_dir" "$t"
      log "已生成 $docs_dir/$t.md"
      missing=$((missing + 1))
    fi
  done
  cat <<EOF

✅ wiki 索引已更新（docs/INDEX.md）。
$([ "$missing" -gt 0 ] && echo "   已补建 $missing 个缺失文档。" || echo "   四份文档均已存在，未覆盖（避免丢失人工补充）。")
    如需重建某一文档，运行:
      bash scripts/wiki.sh <overview|architecture|modules|api>
EOF
}

