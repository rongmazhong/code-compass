# Spec: status-activate

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: activate 输出可复制命令

系统 SHALL 在 `code-compass status activate` 时，依据当前 `stage`（及 `track`）输出**可直接复制执行的命令**，而非仅文字描述。每个阶段映射其下一步命令：

- `idea` → `code-compass product-analysis <name>`
- `product-analysis` → `code-compass status`（检查 spec 是否就绪）
- `planned` → `code-compass dev <slug>`
- `dev` / `implemented` → `code-compass qa`
- `qa` → `code-compass verify`
- `verified` → `code-compass review`
- `reviewed` → `code-compass wiki`
- `summary` → （无后续命令，提示已完成）

命令中的 `<slug>`/`<name>` SHALL 用当前 active 的 slug 实际值替换或明确标注占位。

#### Scenario: planned 阶段输出 dev 命令

- **WHEN** `stage=planned`，active slug 为 `foo`
- **THEN** 输出含 `code-compass dev foo` 的可复制命令

#### Scenario: summary 阶段无后续

- **WHEN** `stage=summary`
- **THEN** 输出"已完成"提示，不含后续命令

### Requirement: activate 命令随 track 裁剪

系统 SHALL 在输出 activate 命令时，依据 `track` 跳过被裁剪阶段对应的命令（与 sop-tiers 的阶段链一致）。例如 `track=small` 时不含 `code-compass review` 相关步骤。

#### Scenario: small track 不含 review

- **WHEN** `track=small`，`stage=verified`
- **THEN** 输出 `code-compass review` 之后的步骤被跳过（small 链无 reviewed）

#### Scenario: research track 直达 summary

- **WHEN** `track=research`，`stage=dev`
- **THEN** 下一步输出 `code-compass status` 推进至 `summary` 的命令
