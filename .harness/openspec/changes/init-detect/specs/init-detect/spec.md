# Spec: init-detect

> OpenSpec 风格的能力 spec（delta）。描述目标状态，每条 Requirement 须可验证。

## ADDED Requirements

### Requirement: 扩充技术栈信号识别

系统 SHALL 在 `_detect_project` 中除既有 go/package.json/pyproject 外，识别以下信号并设定 `PROJ_LANG`/`PROJ_TECH`：Makefile 或 justfile（Make/Just）、Cargo.toml（Rust）、*.csproj/*.sln（DotNet）、CMakeLists.txt（CMake）、mix.exs（Elixir）、Dockerfile（容器化）、含 `#!/bin/sh|bash` 的脚本目录（Shell）、Gemfile（Ruby）、go.mod（已支持，补充构建命令）。无法归类的多信号项目取首个匹配。

#### Scenario: 识别 Rust 项目

- **WHEN** 目标目录含 `Cargo.toml`
- **THEN** `PROJ_LANG` 设为 `Rust`

#### Scenario: 识别 Makefile 项目

- **WHEN** 目标目录含 `Makefile` 且无更高优先级信号
- **THEN** `PROJ_LANG` 设为 `Make`，`PROJ_TECH` 含 `Makefile`

### Requirement: 识别失败显式标注

系统 SHALL 在未能识别任何技术栈信号时，将语言字段置为 `未识别（请手动填写）` 而非静默 `未知` 或空值；并在生成的 docs/INDEX.md 与 rules/workflow.md 中同步该显式标注。

#### Scenario: 无信号项目

- **WHEN** 目标目录无任何已知信号
- **THEN** 语言字段为 `未识别（请手动填写）`，不出现 `未知` 字样

### Requirement: 识别包管理器时预填 workflow 命令

系统 SHALL 在识别到包管理器类信号时，将对应的构建/测试/静态检查命令预填进生成的 `rules/workflow.md`，替换"（未识别，请补充）"占位。映射示例：package.json→`npm test`/`npm run lint`/`npm run build`；Cargo.toml→`cargo test`/`cargo clippy`；pyproject→`pytest`/`ruff`；go.mod→`go test ./...`/`go vet`。

#### Scenario: Node 项目预填命令

- **WHEN** 识别到 package.json 且含 test 脚本
- **THEN** `rules/workflow.md` 的测试字段为 `npm test`，静态检查为 `npm run lint`

#### Scenario: 无命令源保留占位提示

- **WHEN** 识别到语言但无对应标准命令（如纯 Shell）
- **THEN** 相关字段保留"（请补充）"提示但不报错
