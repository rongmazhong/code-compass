---
name: commit
description: |
  按 code-compass 的 git 提交规范生成提交信息。当用户说"提交 / commit / 按规范提交"，
  或开发阶段需要把 worktree 的改动提交时使用。提交格式为 <type>: #{VAPD_ID}#<描述>。
---

# commit —— VAPD 提交规范

code-compass 要求所有提交遵循统一格式，确保需求/缺陷/任务可追溯到 VAPD 标识。

## 提交格式

```
<type>: #{VAPD_ID}#<描述>
```

- **type**（必填）：`feat` / `fix` / `docs` / `refactor` / `test` / `chore` / `style` / `perf` / `build` / `ci`
- **VAPD_ID**（可选，自动携带）：取自 `.harness/state/workflow-state.json` 的 `vapd_id` 字段
  - 需求 `VR` 开头 / 缺陷 `VB` 开头 / 任务 `VT` 开头，如 `VR12345`、`VB2024`、`VT7788`
  - 由 product-analysis 阶段用 `code-compass vapd <ID>` 记录；未记录时该部分省略
- **描述**（必填）：简洁说明本次改动

### 示例

```
feat: #VR12345#开发登录接口
fix: #VB2024#修复空指针崩溃
refactor: 抽离配置加载逻辑
```

## 执行步骤

1. 确认改动已 `git add` 暂存（在 worktree 内操作，落于 `feat/<slug>` 分支）。
2. 确定 `type` 与描述。
3. 运行 **`code-compass commit <type> <描述...>`**，脚本会自动拼接 `vapd_id` 并 `git commit`。

   ```bash
   code-compass commit feat 开发登录接口
   # 若 state.vapd_id=VR12345，实际提交信息为：feat: #VR12345#开发登录接口
   ```

4. **不要**直接手写 `git commit -m`，以免漏带 VAPD 标识。

## 记录 VAPD 标识

若用户在需求描述中显式给定 VAPD ID，先运行 `code-compass vapd <ID>` 写入 state，
后续所有 `code-compass commit` 都会自动携带。

```bash
code-compass vapd VR12345   # 记录需求标识
code-compass vapd           # 查看当前已记录的标识
```
