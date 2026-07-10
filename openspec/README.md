# OpenSpec 存储

本目录采用 [OpenSpec](https://openspec.dev) 风格的 spec 驱动开发结构。

```
openspec/
├── project.md            # 项目级上下文（init 生成）
├── specs/                # 当前能力 spec（truth）
│   └── <capability>/spec.md
└── changes/              # 待实现 / 进行中的变更
    └── <slug>/
        ├── proposal.md   # 为什么做（柏拉图式发问结论）
        ├── tasks.md      # 实现步骤
        └── specs/<capability>/spec.md  # spec delta
```

## 工作流

1. `code-compass design <name>` → 发问收敛，写入 `changes/<slug>/`
2. `code-compass dev <name>` → 基于 spec 实现，推进 `.harness/state/workflow-state.json`
