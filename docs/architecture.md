# 架构设计

> 由 code-compass 生成，已根据本项目实际情况补全。

## 技术栈与运行时

- 语言：纯 Bash（POSIX 友好），无编译、无第三方运行时依赖
- 状态真源：`.harness/state/workflow-state.json`（单一 JSON 文件，被 `guard`/`status`/`commit` 共用）
- JSON 解析：`jq` 优先，缺失时回退 bash 实现（`lib/json.sh` 内的 `_json_get_bash` 等），保证无 `jq` 环境可用

## 顶层目录布局

```
code-compass/
├── skills/code-compass/          # skill 库本体（被安装到 ~/.agents/skills/code-compass）
│   ├── code-compass             # CLI 主入口（~100 行：bootstrap + 模块加载 + 命令分发）
│   ├── lib/                    # 关注点库（被主入口 source）
│   │   ├── json.sh            #   JSON 读写（jq→bash 兜底）
│   │   ├── state.sh          #   状态文件读写/迁移/活动变更
│   │   ├── stages.sh         #   阶段链、track 裁剪、下一步命令
│   │   ├── detect.sh         #   项目探测（语言/构建/测试命令）
│   │   ├── docs.sh           #   wiki 生成（INDEX + 文档脚手架）
│   │   └── worktree.sh      #   git worktree 创建/复用
│   ├── lib/cmds/             # 每个子命令的实现
│   │   ├── use.sh  init.sh  product-analysis.sh  dev.sh
│   │   ├── worktree.sh  vapd.sh  commit.sh  wiki.sh
│   │   ├── guard.sh  status.sh  qa.sh  help.sh
│   ├── harness/              # init 模板（config.json / workflow-state.json）
│   ├── templates/            # openspec 提案/任务/spec 模板
│   ├── tests/                # cli_modular.bats + run_smoke.sh
│   └── SKILL.md              # 库总入口说明
├── .harness/                 # 运行期状态（每个被管理的项目内）
│   ├── config.json           # tracks / stages / 目录约定
│   ├── state/workflow-state.json
│   ├── rules/                # structure / workflow / coding / guard
│   └── openspec/            # specs/（能力真源）+ changes/（变更提案）
├── docs/                      # 项目 wiki（INDEX/overview/architecture/modules/api）
└── AGENTS.md                 # 路由段：强制先分析后开发
```

## 高层结构

```
[用户输入] → code-compass <cmd> [args]
      │
      ├─ 主入口：解析 CC_ROOT（软链感知）→ export → source lib/*.sh + lib/cmds/*.sh
      ├─ 命令分发：case "$cmd" in → cmd_<name> "$@"
      │
      ├─ 读/写 .harness/state/workflow-state.json（状态机真源）
      ├─ 读/写 .harness/config.json（tracks/stages 约定）
      ├─ 读/写 .harness/openspec/changes/<slug>/（spec + tasks）
      └─ 调 git（worktree 隔离、规范化提交）
```

## 关键设计决策

- **主入口极薄**：只做 bootstrap（解析 `CC_ROOT`）、`source` 全部 `lib/*.sh` 与 `lib/cmds/*.sh`、
  以及 `case` 分发；所有逻辑落在 lib。被 `source` 时（如测试）不触发分发，便于复用。
- **CC_ROOT 一次性解析并 export**：lib 内一律通过 `$CC_ROOT` 引用 `harness/`、`skills/` 等资源，
  规避 sourced 文件内 `BASH_SOURCE[0]` 指向调用方导致的路径错乱。
- **JSON 层 jq→bash 兜底**：`lib/json.sh` 同时提供 jq 版与纯 bash 版读写，环境无 `jq` 时自动回退，
  不牺牲"无依赖分发"的硬目标。
- **状态机 + track 裁剪**：阶段链以 `config.json` 的 `stages` 为准；`tracks` 定义不同档位的阶段子集
  （如 `small` 跳过 `review`），`stages.sh` 据此计算"下一步"与闸门结果。
- **先分析后开发硬化为闸门**：`guard` / `dev` / `commit` 在阶段不符时拦截（exit≠0），
  把方法论软纪律变为可机器校验的硬约束。
