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

```bash
# 1. 安装 skill（会把完整工具 bin / 模板 / 子 skill 一并装到 ~/.agents/skills/code-compass）
npx skills add rongmazhong/code-compass
# 或显式指定 git 地址
npx skills add https://github.com/rongmazhong/code-compass

# 2. 让 `code-compass` 命令可用（二选一，本工具不创建任何软链）：
#    a) 加 alias 到你的 shell 配置（~/.bashrc / ~/.zshrc 等）：
alias code-compass="$HOME/.agents/skills/code-compass/code-compass"
#    b) 或将安装目录加入 PATH（写入 shell 配置）：
export PATH="$HOME/.agents/skills/code-compass:$PATH"

# 3. 启用子 skill 并完成当前项目初始化
code-compass using-code-compass
```

> 本工具全局安装位于 `~/.agents/skills/code-compass`，运行命令请用完整路径或上述 alias / PATH，不会在别处生成软链。

### 使用

安装后，在 coding agents 中使用以下命令：

```
# 1. 在你的项目里初始化指南针
执行 `code-compass init` 命令

# 2. 辨明方向：发问 → 生成 OpenSpec 风格的 spec
执行 `code-compass product-analysis feature-xxx`

# 3. 闸门校验：动手前确认阶段是否允许（偏离会拦截）
执行 `code-compass guard`   # 或 `code-compass status --guard`

# 4. 扬帆起航：基于 spec 实现 → 推进 workflow-state
`code-compass dev feature-xxx`
```

---

## 🛠 命令一览

| 命令 | 作用 |
|------|------|
| `code-compass using-code-compass` | 注册并启用 skill 库（校验已全局安装到 `~/.agents/skills/code-compass`，并确保目标项目已 `init`） |
| `code-compass init` | 在当前项目初始化 `.harness/`（state + rules + openspec），并向 `AGENTS.md` 注入路由 |
| `code-compass product-analysis [name]` | 柏拉图式（苏格拉底式）发问，确定需求范围，生成 OpenSpec 风格的 spec 文档 |
| `code-compass dev\|develop [name]` | 基于 spec 进行开发实现（自动创建 git worktree 隔离；计划 → TDD → 子代理 → 验证） |
| `code-compass worktree [list\|prune]` | 管理开发用 git worktree（list 列出 / prune 清理失效注册） |
| `code-compass vapd [ID]` | 记录/查看 VAPD 标识（VR需求 / VB缺陷 / VT任务），写入 `workflow-state.json` |
| `code-compass commit [--exempt] <type> <描述>` | 按 `<type>: #{VAPD_ID}#<描述>` 规范提交（自动携带 vapd_id，并提交前阶段校验） |
| `code-compass status [activate]` | 查看当前工作流状态；`activate` 激活当前阶段自动化流程（状态机思路参考 develop-workflow-rong，已内置，非加载该 skill） |
| `code-compass guard` | **阶段闸门**：动手前校验当前阶段是否允许开发，仍处 `idea`/`product-analysis` 时拦截偏离 |
| `code-compass wiki [topic]` | 更新/重建项目 wiki（`docs/`：概览/架构/模块/API + 索引） |

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
- **阶段闸门 `guard`**：动手前跑 `code-compass guard`，仍处分析前阶段会输出黄色提醒并以**非 0 退出**，视为偏离。
- **`dev` 拦截**：阶段未到 `planned` 无法直接进入开发（可用 `code-compass dev --force` 豁免）。
- **`commit` 校验**：处于 `idea` / `product-analysis` 阶段直接提交实现代码会被拦截（可用 `code-compass commit --exempt` 豁免）。
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
  - 用户在需求描述中**显式给定**时，由 `product-analysis` 阶段用 `code-compass vapd <ID>` 记录；未记录时退化为 `<type>: <描述>`
- 提交一律用 **`code-compass commit <type> <描述...>`**，勿手写 `git commit -m`。

```bash
code-compass vapd VR12345          # 记录需求标识
code-compass commit feat 开发登录接口   # => feat: #VR12345#开发登录接口
```

---

## 📂 目录结构

```
code-compass/
├── README.md
└── skills/
    └── code-compass/        # 以 skills 注册表规范分发的「开发指南针」skill
        ├── SKILL.md         # skill 入口：加载整个库的总说明
        ├── code-compass     # CLI 可执行
        ├── skills/          # 各命令/能力的方法论（agent 可读）
        │   ├── using-code-compass/SKILL.md
        │   ├── init/SKILL.md
        │   ├── product-analysis/SKILL.md
        │   ├── dev/SKILL.md
        │   └── commit/SKILL.md
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
```

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
