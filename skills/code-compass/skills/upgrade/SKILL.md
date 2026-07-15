# code-compass upgrade

刷新**已 init 项目**的 `.harness/` harness 配置，让老项目在 code-compass 升级后不静默失效。
说"升级 / refresh harness / 配置漂移了 / 补上 tracks"时触发。

## 触发场景
- 用户通过 `npx skills add rongmazhong/code-compass` 拉取了新版，但**现有项目**的 `.harness/`
  仍是旧结构（`config.json` 缺 `tracks`、`workflow-state.json` 缺 `updated_at`）。
- `init` 是幂等的，绝不覆盖已存在的 `.harness/`，所以老项目不会自动跟新。

## 用法
```
code-compass upgrade            # 仅刷新当前项目的 harness 配置
code-compass upgrade --self    # 额外从 config.json 的 upgrade_source 拉取并合并 skill 库
```

## 行为契约（与 spec 对齐）
1. **upgrade-refresh-config**：合并模板缺省顶层键（`tracks`/`stages` 等）到 `config.json`，
   仅补缺失键、**不覆盖**用户已填值、**不删**用户键。用 `jq`，无 jq 时降级 `python3`。
2. **upgrade-refresh-state**：确保每个 change 含 `updated_at` 字段（默认 ""），
   复用 `_state_migrate` 处理更老 schema，完整保留 `changes`/`completed` 数据。
3. **upgrade-scope-locked**：**仅**读写 `config.json` + `workflow-state.json`；
   **绝不**碰 `rules/`、`AGENTS.md`、`openspec/`、`issues.md`。
4. **upgrade-self-backup-merge**：`--self` 时先备份用户改过的 `SKILL.md`/`rules` 到
   `.harness.bak/<ts>/`，再从 `upgrade_source`（git 地址或本地目录）同步最新 skill 库，
   最后把用户自定合并回去；未配置 `upgrade_source` 则跳过并提示。

## 幂等
- 全新项目（已含 `tracks`/`updated_at`）跑 `upgrade` → 提示"已是最新"，无改动。
- 可反复运行，不产生重复键或重复备份噪声。

## 不做什么
- 不重新生成 `AGENTS.md` 路由段、不改动 `rules/`（那是用户自定，由 `--self` 仅做备份合并）。
- 不修改 `openspec/` spec 本身——spec 是项目演进事实，升级不应改写。
