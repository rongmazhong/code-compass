---
name: vapd
description: >
   记录/查看 VAPD 标识（VR 需求 / VB 缺陷 / VT 任务），写入 workflow-state.json，供提交携带。运行 `code-compass vapd [ID]` 或说"记录 VAPD / 设置需求 ID"时触发。
---

# vapd —— VAPD 标识管理

VAPD 是 code-compass 对变更来源的分类标识，贯穿 `product-analysis → commit`：
需求 `VR` / 缺陷 `VB` / 任务 `VT` 开头，形如 `VR12345`、`VB2024`、`VT7788`。

## 触发条件

- 用户运行 `code-compass vapd [ID]`
- 用户说"记录 VAPD"、"设置需求 ID"、"这个缺陷编号是 VB2024"
- `product-analysis` 阶段需要把用户显式给定的 ID 落到状态机

## 用法

### `code-compass vapd`（无参）

- 若已 init，打印当前活跃变更的 `vapd_id`（未设置则提示）。
- 未 init 时提醒先 `init`。

### `code-compass vapd <ID>`

1. 校验格式：`_is_vapd` 要求以 `VR` / `VB` / `VT` 开头，否则 `die` 报错。
2. 写入 `.harness/state/workflow-state.json` 的 `vapd_id` 字段（`_set_vapd`）。
3. 提示提交时将自动携带：`<type>: #<ID>#<描述>`。

## 与其它命令的关系

- `product-analysis --vapd <ID>`：在创建变更工作区时一并记录（等价先 `vapd` 再分析）。
- `commit`：拼接 `vapd_id` 进提交信息；为空时退化为 `<type>: <描述>`。
- 状态机真源：`workflow-state.json` 的 `changes.<slug>.vapd_id`。
