# ---------------------------------------------------------------------------
# lib/state.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _state_file ---
_state_file() { echo "$TARGET_DIR/.harness/state/workflow-state.json"; }

# --- _state_ensure_file ---
_state_ensure_file() {
  local f; f="$(_state_file)"
  [ -f "$f" ] && { _state_migrate; return 0; }
  mkdir -p "$(dirname "$f")"
  if command -v jq >/dev/null 2>&1; then
    jq -n '{tool:"code-compass", active:"", changes:{}}' > "$f" 2>/dev/null && return 0
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json;json.dump({"tool":"code-compass","active":"","changes":{}},open(__import__("sys").argv[1],"w"),ensure_ascii=False)' "$f" && return 0
  fi
  warn "未找到 jq/python3，无法初始化状态文件"
  return 1
}

# --- _state_migrate ---
_state_migrate() {
  local f; f="$(_state_file)"
  [ -f "$f" ] || return 0
  # 已含 changes 则跳过
  if command -v jq >/dev/null 2>&1; then
    jq -e 'has("changes")' "$f" >/dev/null 2>&1 && return 0
    local spec; spec="$(jq -r '.spec // ""' "$f" 2>/dev/null)"
    if [ -z "$spec" ]; then
      warn "状态文件为旧结构且无 spec 字段，无法安全迁移（active 置空，原数据保留）。"
      return 0
    fi
    jq --arg s "$spec" '{tool:(.tool//"code-compass"), active:$s,
      changes:{($s):{stage:(.stage//"idea"), branch:(.branch//""), track:(.track//""),
        vapd_id:(.vapd_id//""), updated_at:(.updated_at//""), completed:(.completed//[])}}}' \
      "$f" > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f" && return 0
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$f" <<'PY' && return 0
import json,sys
f=sys.argv[1]
try: d=json.load(open(f))
except: sys.exit(0)
if "changes" in d: sys.exit(0)
spec=d.get("spec","")
if not spec:
    sys.stderr.write("warn:no-spec\n"); sys.exit(0)
new={"tool":d.get("tool","code-compass"),"active":spec,
     "changes":{spec:{"stage":d.get("stage","idea"),"branch":d.get("branch",""),
       "track":d.get("track",""),"vapd_id":d.get("vapd_id",""),
       "updated_at":d.get("updated_at",""),"completed":d.get("completed",[])}}}
json.dump(new,open(f,"w"),ensure_ascii=False,indent=2)
PY
  fi
  warn "无 jq/python3，无法迁移旧状态结构，请手动转换。"
  return 0
}

# --- _state_active ---
_state_active() {
  local f; f="$(_state_file)"
  [ -f "$f" ] || return 0
  _state_migrate
  if command -v jq >/dev/null 2>&1; then
    local a; a="$(jq -r '.active // ""' "$f" 2>/dev/null)"
    [ -z "$a" ] && a="$(jq -r 'if (.changes|type)=="object" then ((.changes|keys)[0]//"") else "" end' "$f" 2>/dev/null)"
    echo "$a"
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$f" <<'PY'
import json,sys
f=sys.argv[1]
try: d=json.load(open(f))
except: sys.exit(0)
a=d.get("active","")
if not a and isinstance(d.get("changes"),dict):
    ks=list(d["changes"].keys()); a=ks[0] if ks else ""
print(a)
PY
  fi
}

# --- _state_list ---
_state_list() {
  local f; f="$(_state_file)"
  [ -f "$f" ] || return 0
  _state_migrate
  if command -v jq >/dev/null 2>&1; then
    jq -r 'if (.changes|type)=="object" then (.changes|keys[]) else empty end' "$f" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$f" <<'PY'
import json,sys
f=sys.argv[1]
try: d=json.load(open(f))
except: sys.exit(0)
if isinstance(d.get("changes"),dict):
    print("\n".join(d["changes"].keys()))
PY
  fi
}

# --- _state_get ---
_state_get() {
  local field="$1" f; f="$(_state_file)"
  [ -f "$f" ] || return 0
  _state_migrate
  local a; a="$(_state_active)"
  [ -z "$a" ] && return 0
  [ "$field" = "spec" ] && { echo "$a"; return 0; }
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg s "$a" --arg f "$field" '(.changes[$s][$f] // "") | if .==null then "" else tostring end' "$f" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$f" "$a" "$field" <<'PY'
import json,sys
f,s,field=sys.argv[1],sys.argv[2],sys.argv[3]
try: d=json.load(open(f))
except: sys.exit(0)
v=d.get("changes",{}).get(s,{}).get(field,"")
print(v if v is not None else "")
PY
  fi
}

# --- _state_get_for ---
_state_get_for() {
  local slug="$1" field="$2" f; f="$(_state_file)"
  [ -f "$f" ] || return 0
  _state_migrate
  [ "$field" = "spec" ] && { echo "$slug"; return 0; }
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg s "$slug" --arg f "$field" '(.changes[$s][$f] // "") | if .==null then "" else tostring end' "$f" 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$f" "$slug" "$field" <<'PY'
import json,sys
f,s,field=sys.argv[1],sys.argv[2],sys.argv[3]
try: d=json.load(open(f))
except: sys.exit(0)
v=d.get("changes",{}).get(s,{}).get(field,"")
print(v if v is not None else "")
PY
  fi
}

# --- _state_set ---
_state_set() {
  local slug="$1" field="$2" val="$3" f; f="$(_state_file)"
  _state_ensure_file || return 1
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  if command -v jq >/dev/null 2>&1; then
    jq --arg s "$slug" --arg f "$field" --arg v "$val" --arg t "$ts" \
      '.active = (if (.active=="" or (.active//"")=="") then $s else .active end)
       | .changes[$s][$f] = $v
       | .changes[$s].updated_at = $t' "$f" > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f" && return 0
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$f" "$slug" "$field" "$val" <<'PY' && return 0
import json,sys
f,s,field,val=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
from datetime import datetime,timezone
d=json.load(open(f))
d.setdefault("changes",{})
if not d.get("active"): d["active"]=s
d["changes"].setdefault(s,{})
d["changes"][s][field]=val
d["changes"][s]["updated_at"]=datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
json.dump(d,open(f,"w"),ensure_ascii=False,indent=2)
PY
  fi
  warn "未找到 jq/python3，无法写入状态"
  return 1
}

# --- _state_ensure ---
_state_ensure() {
  local slug="$1" f; f="$(_state_file)"
  _state_ensure_file || return 1
  if command -v jq >/dev/null 2>&1; then
    jq --arg s "$slug" '.active=$s | .changes[$s].stage=(.changes[$s].stage//"idea")
      | .changes[$s].updated_at=(.changes[$s].updated_at//"")' "$f" > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f" && return 0
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$f" "$slug" <<'PY' && return 0
import json,sys
f,s=sys.argv[1],sys.argv[2]
d=json.load(open(f)); d["active"]=s
d.setdefault("changes",{}).setdefault(s,{})
d["changes"][s].setdefault("stage","idea")
json.dump(d,open(f,"w"),ensure_ascii=False,indent=2)
PY
  fi
  return 1
}

# --- _set_vapd ---
_set_vapd() {
  local id="$1"
  _state_ensure_file >/dev/null 2>&1 || cmd_init >/dev/null 2>&1
  local a; a="$(_state_active)"
  [ -z "$a" ] && a="$(_state_list | head -1)"
  [ -z "$a" ] && { warn "尚无活跃变更，无法写入 VAPD 标识"; return 1; }
  _state_set "$a" vapd_id "$id"
}

# --- _set_stage ---
_set_stage() {
  local slug="$1" stage="$2" branch="${3:-}"
  _state_ensure "$slug" || cmd_init >/dev/null 2>&1
  _state_set "$slug" stage "$stage"
  [ -n "$branch" ] && _state_set "$slug" branch "$branch"
  # 维护 changes[slug].completed（去重）
  local f; f="$(_state_file)"
  if command -v jq >/dev/null 2>&1; then
    jq --arg s "$slug" --arg v "$stage" \
      '.changes[$s].completed |= (if (.changes[$s].completed|type)=="array" then (. + [$v] | unique) else [$v] end)' \
      "$f" > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f"
  elif command -v python3 >/dev/null 2>&1; then
    python3 - "$f" "$slug" "$stage" <<'PY'
import json,sys
f,s,v=sys.argv[1],sys.argv[2],sys.argv[3]
d=json.load(open(f)); d.setdefault("changes",{}).setdefault(s,{})
c=d["changes"][s].get("completed",[])
if not isinstance(c,list): c=[]
if v not in c: c.append(v)
d["changes"][s]["completed"]=c
json.dump(d,open(f,"w"),ensure_ascii=False,indent=2)
PY
  fi
}

# --- _set_track ---
_set_track() {
  local track="${1:-standard}" slug="$2"
  [ -z "$slug" ] && slug="$(_state_active)"
  [ -z "$slug" ] && { warn "尚无活跃变更，无法写入 track"; return 1; }
  _state_set "$slug" track "$track"
}

