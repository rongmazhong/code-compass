# ---------------------------------------------------------------------------
# lib/upgrade.sh (cc-upgrade 变更)
# ---------------------------------------------------------------------------

# --- _config_merge ---
# 把项目 config.json 刷新到模板的缺省顶层键（tracks/stages 等），
# 仅补缺失键、不覆盖用户已填值、不删用户键。返回新增键数。
_config_merge() {
  local cfg="$TARGET_DIR/.harness/config.json" tmpl="$CC_ROOT/harness/config.json"
  [ -f "$cfg" ] || return 0
  [ -f "$tmpl" ] || { warn "无 harness 模板 config.json，跳过配置刷新"; return 0; }
  local added=0
  if command -v jq >/dev/null 2>&1; then
    added="$(jq -nr --slurpfile t "$tmpl" --slurpfile c "$cfg" '
      ($t[0]|keys) as $tk
      | [$tk[] | select(. as $k | ($c[0]|has($k)) | not)] | length' 2>/dev/null)"
    if [ "${added:-0}" -gt 0 ] 2>/dev/null; then
      jq -n --slurpfile t "$tmpl" --slurpfile c "$cfg" '
        ($c[0]) as $cobj | ($t[0]) as $tobj
        | reduce ($tobj|keys[]) as $k
            ($cobj; if has($k) then . else . + {($k): $tobj[$k]} end)' > "$cfg.tmp" 2>/dev/null \
        && mv "$cfg.tmp" "$cfg"
    fi
  elif command -v python3 >/dev/null 2>&1; then
    added="$(python3 - "$cfg" "$tmpl" <<'PY'
import json,sys
cfg,tml=sys.argv[1],sys.argv[2]
c=json.load(open(cfg)); t=json.load(open(tml))
n=sum(1 for k in t if k not in c)
c.update({k:t[k] for k in t if k not in c})
json.dump(c,open(cfg,"w"),ensure_ascii=False,indent=2)
print(n)
PY
)"
  else
    warn "无 jq/python3，无法合并 config.json（请手动补 tracks/stages）"; return 0
  fi
  if [ "${added:-0}" -gt 0 ] 2>/dev/null; then
    warn "config.json 已补 $added 个缺省键（tracks/stages 等），用户原键保留"
  fi
  echo "$added"
}

# --- _state_upgrade ---
# 确保 workflow-state.json 每个 change 含 updated_at 字段（默认 ""），
# 重用 _state_migrate 处理更老的 schema，完整保留 changes 数据。返回是否变动。
_state_upgrade() {
  local f="$TARGET_DIR/.harness/state/workflow-state.json"
  [ -f "$f" ] || return 0
  _state_migrate
  local changed=0
  if command -v jq >/dev/null 2>&1; then
    if jq -e 'any(.changes[]?; (.updated_at // null) == null)' "$f" >/dev/null 2>&1; then
      jq '(.changes[]?) |= if (.updated_at // null) == null then .updated_at="" else . end' \
         "$f" > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f" && changed=1
    fi
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$f" <<'PY' && changed=1
import json,sys
f=sys.argv[1]
try: d=json.load(open(f))
except: sys.exit(0)
for k,v in d.get("changes",{}).items():
    if isinstance(v,dict) and "updated_at" not in v:
        v["updated_at"]=""
json.dump(d,open(f,"w"),ensure_ascii=False,indent=2)
PY
  fi
  [ "$changed" -eq 1 ] && warn "workflow-state.json 已补 updated_at 字段"
  echo "$changed"
}

# --- _self_upgrade ---
# 安装级自升级：先备份用户改过的 SKILL.md / rules，再从 upgrade_source
# 拉取最新 skill 库并合并用户修改回去。upgrade_source 未配置则跳过。
_self_upgrade() {
  local cfg="$TARGET_DIR/.harness/config.json"
  local src=""
  [ -f "$cfg" ] && src="$(jq -r '.upgrade_source // ""' "$cfg" 2>/dev/null)"
  if [ -z "$src" ]; then
    warn "未配置 upgrade_source，跳过 skill 库自升级（项目级刷新仍已执行）。"
    warn "  如需 code-compass 升级时备份+合并你的 SKILL.md/rules 自定，"
    warn "  在 .harness/config.json 加：\"upgrade_source\": \"<git 地址或本地目录>\""
    return 0
  fi
  local ts; ts="$(date +%Y%m%d%H%M%S)"
  local bak="$TARGET_DIR/.harness.bak/$ts"
  mkdir -p "$bak"
  cp -r "$CC_ROOT/skills" "$bak/skills" 2>/dev/null \
    && log "已备份用户自定到 $bak/skills"
  local tmp; tmp="$(mktemp -d)"
  if [ -d "$src" ]; then
    rsync -a --delete "$src/" "$tmp/" 2>/dev/null
  else
    git clone -q "$src" "$tmp" 2>/dev/null || { warn "拉取 upgrade_source 失败： $src"; rm -rf "$tmp" "$bak"; return 1; }
  fi
  # 用最新库覆盖安装目录（保留备份）
  rsync -a --delete "$tmp/" "$CC_ROOT/" 2>/dev/null \
    && log "已从 upgrade_source 同步最新 skill 库"
  # 合并用户自定：把备份里用户改过的 SKILL.md / rules 还原覆盖
  if [ -d "$bak/skills" ]; then
    rsync -a "$bak/skills/" "$CC_ROOT/skills/" 2>/dev/null \
      && log "已合并用户自定 SKILL.md / rules 回安装目录"
  fi
  rm -rf "$tmp"
  log "✅ skill 库自升级完成（备份留于 $bak）"
}

# --- cmd_upgrade ---
cmd_upgrade() {
  local self=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --self) self=1; shift ;;
      -*) warn "未知选项: $1"; shift ;;
      *) break ;;
    esac
  done

  # 项目级：刷新当前项目 .harness/ harness 配置（仅 config.json + workflow-state.json）
  if [ ! -d "$TARGET_DIR/.harness" ]; then
    warn "当前项目尚未 init（无 .harness/），无法 upgrade。请先运行: code-compass init"
    return 1
  fi
  # _config_merge / _state_upgrade 仅输出一个整数；直接取、剥非数字，避免
  # grep 在无匹配时于 set -e+pipefail 下令脚本静默退出。
  local ca cs
  ca="$(_config_merge 2>/dev/null)" || true
  cs="$(_state_upgrade 2>/dev/null)" || true
  ca="$(printf '%s' "$ca" | tr -dc '0-9')"
  cs="$(printf '%s' "$cs" | tr -dc '0-9')"
  ca="${ca:-0}"; cs="${cs:-0}"

  # 范围锁定：绝不触碰 rules/ / AGENTS.md / openspec/ / issues.md（仅 harness 配置）
  log "upgrade 仅刷新 harness 配置（config.json + workflow-state.json），不动 rules/、AGENTS.md、openspec/、issues.md"

  if [ "${ca:-0}" -eq 0 ] && [ "${cs:-0}" -eq 0 ]; then
    log "✅ 已是最新（config.json / workflow-state.json 均无缺失），无需刷新"
  else
    log "✅ 项目 harness 配置已刷新（config 新增 ${ca:-0} 键，state 变动 ${cs:-0} 处）"
  fi

  # 安装级自升级（可选，需配置 upgrade_source）
  if [ "$self" -eq 1 ]; then
    _self_upgrade
  fi
  return 0
}
