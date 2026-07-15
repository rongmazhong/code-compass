# 🧭 code-compass · 开发指南针

> **compass** 是中国古代罗盘 —— 辨方位、定方向、不迷于途。
> **code-compass** 即为「开发指南针」：在需求迷雾中为你定方位，在代码汪洋里指航向，
> 让你始终清楚「现在在哪、下一步往哪走」。

code-compass 不是又一个堆功能的脚手架，而是一套 **spec 驱动的工程方法论编排器**。
它借鉴业界成熟方法论（**superpowers / gstack / OpenSpec / develop-workflow-rong**）的思路，将其内化为一套**自包含**的开发流 ——
编排成一支「先理解问题、再 spec 驱动实现」的虚拟团队，让 AI 编程助手像老练的船长一样，
既懂方向，又懂掌舵。

---

## ✨ 为什么需要开发指南针

- 🌀 **需求迷雾**：想法很多，却说不清到底要做什么。code-compass 用**柏拉图式（苏格拉底式）发问**帮你厘清边界。
- 🧭 **方向迷失**：写着写着就偏离初衷。code-compass 用 **spec 作为唯一事实源**，让每一步都可追溯。
- ⏸️ **中断即失忆**：任务被打断就前功尽弃。code-compass 用**状态机**记录进度，断点续跑。
- 🤖 **方法论散落**：brainstorm、TDD、调试、审查各自为政。code-compass 把它们**编排成一条流水线**（均已内置为自身 skill 的方法论指引，无需另行安装外部 skill 库）。

---

## 🧩 方法论融合

> 下表为 **方法论灵感来源**，**非强制依赖**：code-compass 已将这些方法论内化为自包含的 skill 工作流，无需另行安装 superpowers / gstack 等技能库即可跑通全流程。

| 来源 | 贡献 | 指南针中的角色 |
|------|------|----------------|
| **superpowers** | 方法论优先：brainstorm / TDD / 系统化调试 / 计划驱动 | 掌舵之心 —— 先理解，再动手 |
| **gstack** | 角色化虚拟团队、QA（agent-browser）、审查（review + codex）、发布（/ship） | 船员团队 —— 各司其职，协同推进 |
| **OpenSpec** | spec 驱动的变更管理：`specs/`（truth）+ `changes/`（proposal + tasks + delta） | 海图 —— 唯一的事实源 |
| **develop-workflow-rong** | 自动状态机编排：`.harness/state/workflow-state.json` 阶段推进 | 舵轮 —— 驱动航程前进 |

---

## 🚀 快速开始

code-compass 通过 skills CLI 一键安装（skills 以 GitHub 为注册表，使用 `owner/repo` 形式）：

### 安装与启用

本 skill 通过 skills 注册表分发。安装后把本仓库放进 agent 的 skills 目录即可用，无需配置 shell 或 python3：

```bash
npx skills add rongmazhong/code-compass
# 或显式指定 git 地址
npx skills add https://github.com/rongmazhong/code-compass
```

安装后加载 `using-code-compass` 子 skill 完成当前项目初始化（其散文会指示 agent 调 `bash scripts/use.sh`）。

### 使用

安装后，在 coding agents 中按用户意图加载对应子 skill（需要机械操作时由子 skill 散文指示调 `scripts/*.sh`）：

```
# 1. 在你的项目里初始化指南针
加载 `init` 子 skill（agent 调 bash scripts/init-harness.sh）

# 2. 辨明方向：发问 → 生成 OpenSpec 风格的 spec
加载 `product-analysis` 子 skill（agent 调 bash scripts/product-analysis.sh feature-xxx）

# 3. 闸门校验：动手前确认阶段是否允许（偏离会拦截）
加载 `guard` 子 skill（bash scripts/guard.sh 或 bash scripts/status.sh --guard）

# 4. 扬帆起航：基于 spec 实现 → 推进 workflow-state
加载 `dev` 子 skill（bash scripts/dev.sh feature-xxx）
```

---

## 🛠 意图 → 子 skill

agent 按用户意图直接加载对应子 `SKILL.md`（需要机械操作时由子 skill 散文指示调 `scripts/*.sh`）：

| 用户意图 | 子 skill | 机械操作 |
|----------|----------|----------|
| 启用库 / 接入项目 | `using-code-compass` | `bash scripts/use.sh` |
| 初始化 `.harness/` 运行基座 | `init` | `bash scripts/init-harness.sh` |
| 新功能 / 需求分析 / 出方案 | `product-analysis` | `bash scripts/product-analysis.sh` |
| 按 spec 开发实现 | `dev` | 开头 `bash scripts/guard.sh` + `bash scripts/worktree.sh` |
| 管理 git worktree | `worktree` | `bash scripts/worktree.sh` |
| 记录/查看 VAPD 标识 | `vapd` | `bash scripts/vapd.sh` |
| 按规范提交 | `commit` | `bash scripts/commit.sh` |
| 查看状态 / 激活续跑 / 闸门 | `status` | `bash scripts/status.sh` |
| 阶段闸门校验 | `guard` | `bash scripts/guard.sh` |
| 更新/重建项目 wiki | `wiki` | `bash scripts/wiki.sh` |
| 跑 QA / 验证覆盖 / 代码评审 | `qa` | `bash scripts/qa.sh` / `verify.sh` / `review.sh` |
| 刷新 harness 配置 | `upgrade` | `bash scripts/upgrade.sh` |

---

## 🧭 航程状态机

`.harness/state/workflow-state.json` 记录进度，中断后可从断点续跑。
这是指南针的「舵轮」，始终指向当前所处的阶段：

```
idea → product-analysis → planned → dev → implemented → qa → verified → reviewed → summary
```

---

## 🚧 强制约束（先分析后开发）

指南针不只是「提供」方法论，更会**强制** agent 走：任何代码改动意图，默认先经
`product-analysis` 生成已确认 spec，阶段到达 `planned` 后才允许 `dev`。把软纪律硬化为带拦截的硬约束：

- **触发词 → 必调 skill**：检测到「新功能 / 做客户端 / 实现 X」等意图时，优先调 `product-analysis` 而非直接编辑。
- **「继续 / 直接做」闸门**：`stage` 仍处 `idea` / `product-analysis` 时，用户说"继续 / 做吧"也不得直接进入编码，须先产出 spec 骨架或澄清清单。
- **阶段闸门 `guard`**：动手前加载 `guard` 子 skill（调 `bash scripts/guard.sh`），仍处分析前阶段会输出黄色提醒并以**非 0 退出**，视为偏离。
- **`dev` 拦截**：阶段未到 `planned` 无法直接进入开发（可用 `bash scripts/dev.sh --force` 豁免）。
- **`commit` 校验**：处于 `idea` / `product-analysis` 阶段直接提交实现代码会被拦截（可用 `bash scripts/commit.sh --exempt` 豁免）。
- **豁免机制**：`dev --force` / `commit --exempt` / 环境变量 `CODE_COMPASS_GUARD=off`（关闭全部闸门，仅调试用）。

`init` 会向 `AGENTS.md` 注入这份强制约束，并生成 `.harness/rules/guard.md` 作为契约文档。

---

## 📝 提交规范（VAPD）

所有 git 提交必须遵循统一格式，便于需求/缺陷/任务追溯：

```
<type>: #{VAPD_ID}#<描述>
```

- **type**：`feat` / `fix` / `docs` / `refactor` / `test` / `chore` / `style` / `perf` / `build` / `ci`
- **VAPD_ID**（自动携带）：取自 `.harness/state/workflow-state.json` 的 `vapd_id`
  - 需求 `VR` 开头 / 缺陷 `VB` 开头 / 任务 `VT` 开头，如 `VR12345`
  - 用户在需求描述中**显式给定**时，由 `product-analysis` 阶段用 `bash scripts/vapd.sh <ID>` 记录；未记录时退化为 `<type>: <描述>`
- 提交一律用 **`bash scripts/commit.sh <type> <描述...>`**，勿手写 `git commit -m`。

```bash
bash scripts/vapd.sh VR12345          # 记录需求标识
bash scripts/commit.sh feat 开发登录接口   # => feat: #VR12345#开发登录接口
```

---

## 📂 目录结构

```
code-compass/
├── README.md
└── skills/
    └── code-compass/        # 以 skills 注册表规范分发的「开发指南针」skill
        ├── SKILL.md         # skill 入口：加载整个库的总说明
        ├── scripts/         # 唯一代码目录：可独立运行的机械工具脚本
        │   ├── _common.sh   #   共享实现（json/state/stages/detect/docs/worktree 等底层函数）
        │   └── <x>.sh       #   各能力自实现：bash scripts/<x>.sh
        ├── skills/          # 各子能力的方法论（agent 可读的子 skill）
        │   ├── using-code-compass/SKILL.md
        │   ├── init/SKILL.md
        │   ├── product-analysis/SKILL.md
        │   ├── dev/SKILL.md
        │   ├── commit/SKILL.md
        │   ├── status/SKILL.md
        │   ├── guard/SKILL.md
        │   └── wiki/SKILL.md
        ├── harness/         # init 注入目标项目的模板
        │   ├── AGENTS.md.harness
        │   ├── config.json
        │   ├── workflow-state.json
        │   └── openspec/    # openspec 模板（project.md / README.md）
        │       ├── project.md
        │       └── README.md
        └── templates/       # product-analysis/dev 生成的文档模板
            ├── proposal.md
            ├── tasks.md
            └── spec.md
# 注：仓库根 `tests/code-compass/` 为测试目录，不随 skill 包分发（已从 skills/code-compass/tests 移出）

目标项目被 `init` 后会产生：

```
your-project/
├── .harness/
│   ├── config.json
│   ├── state/workflow-state.json
│   ├── rules/{structure.md,workflow.md,coding.md,guard.md}
│   └── openspec/           # spec 驱动变更管理（OpenSpec 风格）
│       ├── project.md
│       ├── specs/
│       └── changes/<slug>/{proposal.md,tasks.md,specs/}
├── docs/                    # 项目 wiki（AI agent 入口）
│   ├── INDEX.md             # 索引
│   ├── overview.md          # 项目概览
│   ├── architecture.md      # 架构设计
│   ├── modules.md           # 核心模块
│   └── api.md               # 功能清单及 API 接口
└── AGENTS.md                # 已注入 code-compass 路由段
```

---

## 🎯 适用场景

- 你有一个想法，但还没想清楚要做什么 → `product-analysis` 帮你**辨方位**
- 你接手一个陌生项目，想快速理解全貌 → `wiki` 生成**项目海图**
- 你有明确 spec，想稳稳落地 → `dev` 进入**计划驱动的航行**
- 你的任务常被中断，需要断点续跑 → 状态机**记住你的航程**

---

## 📜 License

MIT
