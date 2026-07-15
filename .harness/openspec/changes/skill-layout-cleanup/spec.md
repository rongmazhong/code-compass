
## Implementation Notes（收尾期补充）

- 实施中发现并修复 `scripts/_common.sh` 中 `_set_stage` 的既有 bug：原 `jq` 在 `|=` 的 RHS
  仍写 `.changes[$s].completed|type`，而 `|=` RHS 的 `.` 已是 `completed` 值本身，导致
  `Cannot index array with string "changes"` 报错；`set -e` 下 `qa` 以退出码 5 终止，且
  `changes[slug].completed` 里程碑数组始终无法写入。修正为直接使用 `type`（RHS 上下文即该值）。
  该修复不改变任何能力对外行为，仅使阶段推进正确记录 `completed` 并让 `qa` 正常退出 0。
