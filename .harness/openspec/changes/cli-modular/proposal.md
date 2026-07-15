# proposal.md — cli-modular

## 问题本质

`skills/code-compass/code-compass` 已膨胀至 ~2000 行单文件巨石，所有子命令、JSON
读写、状态管理、项目探测、文档生成、worktree 管理全部耦合在一起。新增/修
改任一命令的 churn 与回归风险递增，且无法对单个关注点独立测试。

## 档位（tier）

**refactor（重构）**——不改变任何命令的外部行为与 CLI 表面，只重排内部
文件结构；成功后走完整 `qa → verified → reviewed`。

## 关键决策（已与用户确认）

1. **拆分粒度**：按 6 个关注点拆成 `lib/*.sh` + `lib/cmds/*.sh`，而非"每命令一文件"。
2. **测试先行**：先在现有巨石上加 `bats` 集成测试（guard/commit/status/init
   回归，含 `harness` 模板 bug 的防回归），拆分过程中保持全绿。
3. **JSON 抽象层原样保留**：`jq → bash` 兜底不变，与已合并的
   `cli-robustness-hardening` 决策一致；本次**不**删除 bash 兜底、不重新引入 python3。

## 非目标（边界）

- 不修改任何 `cmd_*` 的外部行为、参数、输出格式或 CLI 表面。
- 不删除 `jq → bash` 兜底（保留最低限度环境可用性）。
- 不重命名 `code-compass` 可执行文件。
- 不改动 `harness/` 模板语义（仅确保 lib 引用的路径正确）。

## 成功信号（可观测）

- `bash -n` 对 main 及所有 `lib/*.sh`、`lib/cmds/*.sh` 通过。
- 现有全部命令行为不变：
  - `status --all` 多变更并行、`status activate` 输出可复制命令（track 感知）；
  - `qa`/`verify`/`review` 正常；
  - `product-analysis --append`/`--force` 正常；
  - `tracks`（research/small/standard/standard+/refactor）阶段链正确。
- `bats` 集成测试全绿（guard 拦截/放行、commit VAPD 校验/`--exempt`、
  status 多变更与 track、init 生成含 `tracks` 的 config 与新 schema state）。
- 拆分后 main 文件仅保留 bootstrap + `source lib/*` + dispatch `case`（行数显著下降）。
