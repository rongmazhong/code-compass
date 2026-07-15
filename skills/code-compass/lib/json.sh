# ---------------------------------------------------------------------------
# lib/json.sh  (auto-extracted by cli-modular refactor)
# ---------------------------------------------------------------------------

# --- _tmpfile ---
_tmpfile() { printf '%s.tmp.%s' "$1" "$$"; }

# --- _json_valid ---
_json_valid() {
  local file="$1"
  [ -f "$file" ] || return 1
  if command -v jq >/dev/null 2>&1; then
    jq empty "$file" >/dev/null 2>&1 && return 0 || return 1
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$file" <<'PY' && return 0 || return 1
import json, sys
try:
    json.load(open(sys.argv[1])); sys.exit(0)
except Exception:
    sys.exit(1)
PY
  fi
  return 0
}

# --- _json_get ---
_json_get() {
  local file="$1" field="$2"
  [ -f "$file" ] || return 1
  if command -v jq >/dev/null 2>&1; then
    local v; v="$(jq -r --arg f "$field" '.[$f] // ""' "$file" 2>/dev/null)"
    printf '%s\n' "$v"; return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$file" "$field" <<'PY'
import json, sys
try: print(json.load(open(sys.argv[1])).get(sys.argv[2], ""))
except Exception: pass
PY
    return 0
  fi
  _json_get_bash "$file" "$field"
}

# --- _json_get_bash ---
_json_get_bash() {
  local file="$1" field="$2" line val
  line="$(grep -oE "\"$field\"[[:space:]]*:[[:space:]]*\"?[^\",}\r]*\"?" "$file" 2>/dev/null | head -1)"
  [ -z "$line" ] && return 0
  val="${line#*:}"
  val="${val#"${val%%[![:space:]]*}"}"
  val="${val%"${val##*[![:space:]]}"}"
  case "$val" in '"'*) val="${val#\"}"; val="${val%\"}" ;; esac
  [ -n "$val" ] && printf '%s\n' "$val"
}

# --- _json_set ---
_json_set() {
  local file="$1" field="$2" value="$3"
  [ -f "$file" ] || return 1
  if command -v jq >/dev/null 2>&1; then
    local tmp; tmp="$(_tmpfile "$file")"
    if jq --arg f "$field" --arg v "$value" '.[$f] = $v' "$file" > "$tmp" 2>/dev/null; then
      mv "$tmp" "$file"; return 0
    fi
    rm -f "$tmp"
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$file" "$field" "$value" <<'PY'
import json, sys
p, f, v = sys.argv[1:4]
try: d = json.load(open(p))
except Exception: d = {}
d[f] = v
json.dump(d, open(p, "w"), indent=2, ensure_ascii=False)
PY
    return 0
  fi
  warn "未找到 jq/python3，使用纯 bash 兜底写入（可能不保证 JSON 格式完美）"
  _json_set_bash "$file" "$field" "$value"
}

# --- _json_set_bash ---
_json_set_bash() {
  local file="$1" field="$2" value="$3" tmp
  tmp="$(_tmpfile "$file")"
  grep -vE "\"$field\"[[:space:]]*:" "$file" 2>/dev/null > "$tmp" || true
  printf '  "%s": "%s"\n' "$field" "$value" >> "$tmp"
  mv "$tmp" "$file"
  return 0
}

# --- _json_add_completed ---
_json_add_completed() {
  local state="$1" stage="$2"
  if command -v jq >/dev/null 2>&1; then
    local tmp; tmp="$(_tmpfile "$state")"
    if jq --arg s "$stage" '.completed |= (if . then (. + [$s] | unique) else [$s] end)' "$state" > "$tmp" 2>/dev/null; then
      mv "$tmp" "$state"; return 0
    fi
    rm -f "$tmp"
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$state" "$stage" <<'PY'
import json, sys
p, s = sys.argv[1:3]
try: d = json.load(open(p))
except Exception: d = {}
d.setdefault("completed", [])
if s not in d["completed"]:
    d["completed"].append(s)
json.dump(d, open(p, "w"), indent=2, ensure_ascii=False)
PY
    return 0
  fi
  return 0
}

