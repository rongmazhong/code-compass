# 架构设计

> 由 code-compass 生成，已根据本项目实际情况补全。

## 技术栈与运行时

- 语言：纯 Bash（POSIX 友好），无编译、无第三方运行时依赖
- 状态真源：`.harness/state/workflow-state.json`（单一 JSON 文件，被 `guard`/`status`/`commit` 共用）
- JSON 解析：`jq` 优先，缺失时回退 bash 实现（`scripts/_common.sh` 内的 `_json_get_bash` 等），保证无 `jq` 环境可用
- **无 CLI**：本库不提供可执行主入口，只作为 agent 的 skill 库工作；机械活由 `scripts/*.sh` 独立脚本承担，终端用户可直接 `bash scripts/x.sh` 运行。

## 两层结构

本库由「**子 skill 层** + **scripts/ 工具层**」两层构成：

- **子 skill 层（`skills/code-compass/skills/`）**：12 个独立子 skill，是面向用户意图的「一等公民」。其
  `SKILL.md` 的 `description` 是意图触发词（用户说「新功能 / 做客户端 / 实现 X / 需求分析」等自然说法即触发），
  正文是方法论散文 + 调 `scripts/*.sh` 的机械步骤。agent 在会话中按意图加载对应子 skill。
- **scripts/ 工具层（`skills/code-compass/scripts/`）**：唯一代码目录，包含可独立运行的 bash 脚本，是真正的机械执行体。
  子 skill 内部按需 `bash scripts/x.sh` 调用它们，终端用户也可直接运行。每个 `scripts/<x>.sh` 在
  `source _common.sh` 后自包含实现其能力，不再有独立的 lib 层；`scripts/_common.sh` 承载所有共享底层实现
  （`json`/`state`/`stages`/`detect`/`docs`/`worktree` 等函数与 `cmd_*` 命令实现），被各脚本统一 source。

## 顶层目录布局

```
code-compass/
├── skills/code-compass/          # skill 库本体（被安装到 ~/.agents/skills/code-compass）
│   ├── scripts/                 # 唯一代码目录：可独立运行的 bash 脚本（机械活）
│   │   ├── _common.sh          #   共享实现：json/state/stages/detect/docs/worktree 等底层函数 + cmd_*
│   │   ├── init-harness.sh     #   初始化 .harness/ + docs/ + AGENTS 路由
│   │   ├── product-analysis.sh #   脚手架需求分析工作区
│   │   ├── dev.sh              #   基于 spec 开发（内部调 guard + worktree）
│   │   ├── worktree.sh         #   git worktree 管理 list/prune
│   │   ├── vapd.sh             #   记录/查看 VAPD 标识
│   │   ├── commit.sh           #   按 `<type>: #{VAPD_ID}#<描述>` 规范提交
│   │   ├── status.sh           #   查看/激活状态
│   │   ├── guard.sh            #   阶段闸门，exit code 拦截
│   │   ├── qa.sh / verify.sh / review.sh  # QA 三连
│   │   ├── wiki.sh             #   重建 docs/
│   │   ├── upgrade.sh          #   刷新 harness 配置
│   │   ├── use.sh              #   注册启用 skill 库
│   │   └── state.sh            #   读写 workflow-state.json（get/set/set-stage/set-vapd）
│   ├── skills/                 # 子 skill 层：12 个独立子 skill
│   │   ├── init / product-analysis / dev / worktree / vapd
│   │   ├── commit / status / guard / qa / wiki / upgrade / using-code-compass
│   │   └── <name>/SKILL.md     #   意图触发 description + 方法论散文 + 调 scripts 步骤
│   ├── harness/                # init 模板（config.json / workflow-state.json / AGENTS.md.harness）
│   ├── templates/             # openspec 提案/任务/spec 模板
│   └── SKILL.md                # 库总入口说明
# 注：仓库根 `tests/code-compass/` 为测试目录，不随 skill 包分发（已从 skills/code-compass/tests 移出）
├── .harness/                 # 运行期状态（每个被管理的项目内）
│   ├── config.json           # tracks / stages / 目录约定
│   ├── state/workflow-state.json
│   ├── rules/                # structure / workflow / coding / guard
│   └── openspec/            # specs/（能力真源）+ changes/（变更提案）
├── tests/code-compass/        # 测试（仓库根，不随包分发）
├── docs/                      # 项目 wiki（INDEX/overview/architecture/modules/api）
└── AGENTS.md                 # 路由段：强制先分析后开发
```

## 高层数据流

```
[用户自然语言意图] → agent 按 SKILL.md description 触发对应子 skill
      │
      ├─ 子 skill 散文：收敛需求 / 解释方法论 / 决定下一步
      ├─ 子 skill 调 bash scripts/x.sh [args]（机械执行）
      │
       ├─ scripts 内部 source _common.sh 复用底层函数
      ├─ 读/写 .harness/state/workflow-state.json（状态机真源）
      ├─ 读/写 .harness/config.json（tracks/stages 约定）
      ├─ 读/写 .harness/openspec/changes/<slug>/（spec + tasks）
      └─ 调 git（worktree 隔离、规范化提交）
```

## 关键设计决策

- **无 CLI，子 skill 为一等公民**：agent 不再跑 `code-compass <cmd>`。机械活统一收敛到
  `scripts/*.sh`，子 skill 的 `SKILL.md` 只描述「何时触发 + 怎么调脚本」，职责清晰、可脱离上下文单独运行。
- **scripts 可独立运行**：每个脚本自举（`source _common.sh` 解析 `CC_ROOT`），终端用户也能直接
  `bash scripts/x.sh`；既被子 skill 调用，也对外可用。
- **lib/ 已移除，实现并入 scripts/_common.sh**：原 `lib/*.sh` 不再存在，其共享函数已并入
  `scripts/_common.sh`，由每个 `scripts/<x>.sh` 在开头 `source _common.sh` 复用，
  避免独立 lib 层耦合，降低分发与维护成本。
- **JSON 层 jq→bash 兜底**：`scripts/_common.sh` 同时提供 jq 版与纯 bash 版读写，环境无 `jq` 时自动回退，
  不牺牲「无依赖分发」的硬目标。
- **状态机 + track 裁剪**：阶段链以 `config.json` 的 `stages` 为准；`tracks` 定义不同档位的阶段子集
  （如 `small` 跳过 `review`），`stages.sh` 据此计算「下一步」与闸门结果。
- **先分析后开发硬化为闸门**：`dev` / `commit` 子 skill 在开头调 `bash scripts/guard.sh`（exit≠0 即拦截），
  把方法论软纪律变为可机器校验的硬约束；无独立 `guard` 命令，闸门内嵌于开发/提交流程。
