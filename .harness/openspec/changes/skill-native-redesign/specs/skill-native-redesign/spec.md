# Specification: skill-native-redesign

> OpenSpec 风格的能力 spec（delta）。描述目标状态：code-compass 由「CLI 中枢」重排为「纯 skill 库 + scripts 工具层」。
> 每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: 移除顶层 CLI 调度器

系统 SHALL 删除 `skills/code-compass/code-compass` 可执行文件，且仓库内不得残留任何
`code-compass` 命令入口（`cc.sh` 等别名壳亦删除）。

#### Scenario: 仓库无 CLI 入口

- **WHEN** 在 `skills/code-compass/` 下查找可执行脚本与 `code-compass` 字面引用
- **THEN** 不存在可直接执行的 `code-compass` 命令；README/AGENTS.md 的调用示例不再出现 `code-compass <cmd>`

#### Scenario: 存量项目不受破坏

- **WHEN** 一个已 `init` 的项目（含 `.harness/`、`openspec/`、`AGENTS.md` 路由段）所在仓库移除了 CLI
- **THEN** 该项目仍可经 agent 加载子 skill 续跑，state/openspec 数据完好可读

### Requirement: 顶 SKILL.md 改为意图触发地图

系统 SHALL 将 `skills/code-compass/SKILL.md` 的「核心命令」表改为「意图 → 子 skill」映射；
删除 alias/PATH/python3 安装前置，改为说明「skill 进 agent 技能目录即可用」。

#### Scenario: 触发地图无命令拼写

- **WHEN** 阅读顶 SKILL.md
- **THEN** 表中每项指向 `skills/<name>/SKILL.md`，不再以「运行 code-compass X」为首选触发语；安装段无 alias/PATH 步骤

#### Scenario: 安装零门槛

- **WHEN** 用户仅把本仓库放入 agent 的 skills 目录
- **THEN** 顶 SKILL.md 说明方法论即可用，无需配置 shell 环境变量或 python3 前置

### Requirement: 子 skill 升为一等公民（意图触发）

系统 SHALL 将 12 个能力（`using-code-compass`/`init`/`product-analysis`/`dev`/`worktree`/
`vapd`/`commit`/`status`/`guard`/`wiki`/`qa`/`upgrade`）各自固化为独立子 skill，
每个 `SKILL.md` 的 description 改写为**意图触发**（含 when，pushy 风格、覆盖用户自然说法），
正文为「解释 why 的方法论散文 + 调用 `scripts/*` 的机械步骤」。

#### Scenario: description 不含命令拼写

- **WHEN** 检查任一个子 skill 的 frontmatter description
- **THEN** 不含「运行 code-compass X」字样；改为「用户说『新功能/做客户端/实现 X』或按本库方法论工作时触发」类表述

#### Scenario: 正文指引调用脚本而非命令

- **WHEN** 子 skill 需要建目录/读写 state/跑 git worktree/格式化提交
- **THEN** 正文指示 agent 运行 `bash "$CC_SKILL_DIR/scripts/<x>.sh"`，而非 `code-compass <cmd>`

### Requirement: 新增 scripts 工具层

系统 SHALL 在 `skills/code-compass/scripts/` 提供聚焦的确定性脚本，每个只做一件事且可独立 `bash` 运行：
`init-harness.sh`（铺 `.harness/`+`docs/`+AGENTS 路由）、`state.sh`（读写 `workflow-state.json`：
get/set stage、get/set vapd_id、list、active）、`guard.sh`（阶段闸门、退出码）、
`worktree.sh`（create/list/prune）、`commit.sh`（拼 `<type>: #{VAPD_ID}#<desc>` + git commit）、
`wiki.sh`（生成 `docs/`）、`vapd.sh`（记录/显示 VAPD）。`upgrade` 的逻辑亦落此层。

#### Scenario: 脚本可独立运行

- **WHEN** 终端用户直接执行 `bash skills/code-compass/scripts/init-harness.sh`
- **THEN** 行为与移除 CLI 前 `code-compass init` 一致，无需任何顶层分发器

#### Scenario: state 读写保留 jq→bash 兜底

- **WHEN** 环境无 jq，仅 bash
- **THEN** `state.sh` 走 bash 兜底分支，`workflow-state.json` 读写结果与重构前字节级一致

### Requirement: 硬约束下沉到子 skill + guard.sh

系统 SHALL 在 `dev`/`commit` 子 skill 开头即指示 agent 调用 `scripts/guard.sh`，
并**解释为何跳过分析会导致需求漂移**，再据退出码决定继续或中止；不再有独立 `guard` 命令。

#### Scenario: idea 阶段被拦截

- **WHEN** `stage` 为 `idea`/`product-analysis`，`dev` 子 skill 开头调用 `guard.sh`
- **THEN** `guard.sh` 非 0 退出，`dev` 子 skill 指示 agent 先产出 spec 骨架，不进入编码

#### Scenario: planned 阶段放行

- **WHEN** `stage` 已达 `planned` 及以后
- **THEN** `guard.sh` 0 退出，`dev` 子 skill 继续后续步骤

### Requirement: AGENTS.md 路由段去命令化

系统 SHALL 更新 `harness/AGENTS.md.harness` 模板与已注入项目的 AGENTS.md 路由段，
将「运行 code-compass guard/commit/...」改为「加载对应子 skill / 调 `scripts/*`」，
保留方法论强制约束语义不变。

#### Scenario: 模板无命令引用

- **WHEN** 检查 `harness/AGENTS.md.harness`
- **THEN** 路由段不再出现 `code-compass <cmd>`，改为「触发 `<子skill>` / 调 `scripts/*`」

#### Scenario: 存量 AGENTS.md 可平滑更新

- **WHEN** 对已 init 项目重跑 `scripts/init-harness.sh` 或手动同步路由段
- **THEN** 旧 `code-compass <cmd>` 引用被替换为子 skill/脚本引用，强制约束段落语义不变

### Requirement: 状态/schema 兼容存量

系统 SHALL 保持 `workflow-state.json` 与 `config.json`（tracks/stages）既有 schema 不变；
`state.sh`/各脚本仅复用既有字段，不引入新键、不破坏已 init 项目。

#### Scenario: 存量 state 可读

- **WHEN** 一个使用旧 schema 的 `.harness/state/workflow-state.json`
- **THEN** `state.sh` 读取 `stage`/`vapd_id`/`completed` 正常，无报错、无静默丢字段

### Requirement: 测试先行 + 回归护城河

系统 SHALL 在 `skills/code-compass/tests/` 提供 `bats`（或 `bash -n` + smoke）覆盖：
`init-harness.sh` 幂等、`guard.sh` 闸门（idea 非0 / planned 0）、`commit.sh` VAPD 格式与豁免、
`state.sh` 读写。**测试须在架构改造中全程保持全绿**（吸收原 `cli-modular` 测试诉求）。

#### Scenario: init 幂等防回归

- **WHEN** 临时 `TARGET_DIR` 重复跑 `init-harness.sh` 两次
- **THEN** 第二次无副作用，`config.json` 含 `tracks`、`workflow-state.json` 为新 schema

#### Scenario: guard 闸门

- **WHEN** `stage` 为 `idea`
- **THEN** `guard.sh` 非 0 退出；`planned` 及以后 0 退出

### Requirement: 子 skill description 触发率达标

系统 SHALL 对 12 个子 skill 的 description 用 skill-creator `run_loop` 跑触发率评测
（20 条 should/should-not 查询），确保意图触发准确、不漏触发（under-trigger 被抑制）。

#### Scenario: 触发率评测

- **WHEN** 对每个子 skill 运行触发评测
- **THEN** 在 held-out 测试集上触发准确率达预期阈值，近义/口语化说法（如「需求分析」「出方案」）能正确触发对应子 skill
