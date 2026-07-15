# Tasks: sop-tiers

> 将 spec 的 Requirements 拆成可独立验证的实现步骤。每完成一项勾选 [x]。

## 1. 准备

- [x] 在 `config.json` 新增 `tracks` 字段（research/small/standard/standard+/refactor 五条有序阶段数组）

## 2. 实现（按 Requirement 拆解）

- [x] Requirement 1: tracks 映射配置（`_track_stages <track>` 回退 `stages`）
  - [x] 验证：`--track bogus` 时 status 回退完整 9 阶段链
- [x] Requirement 2: product-analysis 选定并写入 track（`--track` 选项 + `_set_track`，缺省 standard）
  - [x] 验证：`product-analysis demo-small --track small` 后 state.track=small
- [x] Requirement 3: status 按 track 渲染阶段链（`_stage_chain` 接收 active track）
  - [x] 验证：small 链不含 reviewed；research 链仅到 summary；standard 含 reviewed
- [x] Requirement 4: guard 按 track 校验阶段合法性（`_can_code` 基于 track 阶段集合）
  - [x] 验证：small track 的 verified 闸门通过；idea 仍拦截

## 3. 验证

- [x] 运行测试套件 / lint（`bash -n` 语法校验通过）
- [x] 手动验证：small/research/standard/bogus 四种 track 的 status 与 guard 行为正确
- [x] 完成前验证（verification-before-completion）
