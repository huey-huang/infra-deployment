# 操作记录

本文件记录 `infra-deployment` 仓库及其部署链路的关键操作。记录以追加方式维护，禁止覆盖历史条目。每条记录应包含操作者、范围、变更、验证结果和后续动作。

> 说明：前两条为根据本次会话已完成操作补录的历史记录；后续操作从第 003 条开始连续编号。

## 记录 001：四仓库初始化

- 时间：2026-09-12（历史补录）
- 操作者：Codex / 用户确认
- 范围：GitHub 仓库和本地 `repo-seeds/` 工作目录
- 目标：将 Directus 平台、n8n AI 打标、素材基础信息和基础设施部署拆分为四个独立仓库。
- 操作：
  - 创建 `directus-platform`、`n8n-ai-tagging`、`asset-metadata-service`、`infra-deployment` 四个仓库。
  - 为每个仓库建立 README、基础目录、配置模板和最小 CI。
  - 初始化 `main`、`develop` 和 `v0.1.0` 发布基线。
  - 将 `repo-seeds/` 加入外层历史仓库的 `.gitignore`，避免新仓库内容混入旧仓库。
- 安全边界：没有提交 PEM、Token、API Key、`.env`、数据库密码或备份数据。
- 验证：四个本地仓库均可检查，三个服务仓库的 `main`、`develop`、`v0.1.0` 已建立；基础设施仓库的 `main`、`develop`、`v0.1.0` 已建立。
- 后续：所有功能修改必须从 `feature/*` 分支开始，经 PR 合并到 `develop`。

## 记录 002：基础设施部署骨架

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`infra-deployment` 仓库
- 分支：`feature/bootstrap-and-ci`
- 提交：`d39b1c8 feat: add environment deployment foundations`
- 目标：建立可审计的 staging / production 部署基础，但暂不连接 AWS 或执行远程变更。
- 操作：
  - 增加 staging / production 环境配置模板。
  - 增加版本矩阵契约，要求使用不可变 SemVer Git Tag。
  - 将 Ubuntu bootstrap 从占位脚本升级为幂等安装 Docker、Git、jq、unzip 的脚本。
  - 增加 `scripts/validate.sh`、`scripts/deploy.sh` 和环境说明。
  - 增加基础设施验证、staging 流程和 production 手动流程工作流。
  - 明确 `deploy.sh` 第一阶段只生成 dry-run 计划，未配置 SSH/SSM 远程传输。
- 验证：
  - `bash scripts/validate.sh` 通过。
  - `bash scripts/deploy.sh staging` 通过，确认未接触远程主机。
  - `bash scripts/deploy.sh production` 通过，确认未接触远程主机。
  - `bash -n` 脚本语法检查通过。
- Git：功能分支已推送至 GitHub，可创建 PR 合并到 `develop`。
- 后续：先审阅并合并 PR；再设计受限的 SSH 或 AWS SSM 部署通道，不能直接将 dry-run 改为远程执行。

## 记录 003：启用操作日志制度

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`infra-deployment/docs/OPERATION_LOG.md`
- 分支 / 提交：`feature/bootstrap-and-ci` / 待提交
- 目标：让后续仓库修改、验证、提交和部署动作可追溯。
- 操作：
  - 新增本操作日志文件。
  - 补录仓库初始化和基础设施部署骨架两次历史操作。
  - 增加统一的操作记录模板和追加规则。
- 安全边界：只记录过程元数据和验证结果，不记录任何真实密钥、Token、PEM 或密码。
- 验证：日志文件已纳入仓库，脚本校验和 staging dry-run 通过。
- 后续：所有重要操作从记录 004 开始连续追加。

## 记录 004：Directus 平台 staging 基础配置

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`directus-platform` 仓库
- 分支 / 提交：`feature/staging-foundation` / `59fc0bc`
- 目标：为 Directus 建立 local、staging、production 可区分的 Compose 基础配置。
- 操作：
  - 增加 staging / production 环境模板和独立 Compose project name。
  - 使用独立 PostgreSQL、上传文件 Volume，降低环境误连风险。
  - 增加 Directus 容器健康检查、日志级别、缓存和时区配置。
  - 增加 Compose 校验脚本及 CI 调用。
  - 修正一次脚本落入外层旧仓库的路径问题，外层未保留该脚本。
- 安全边界：只提交 `.env.example` 模板；密码、Secret、Token 和生产域名凭证仍由部署环境注入。
- 验证：Shell 语法检查和 `git diff --check` 通过；本机未安装 Docker，因此 Compose 实际解析暂未执行，CI 将在 GitHub Actions 中执行。
- Git：功能分支已推送至 GitHub。
- 后续：创建 PR 合并到 `develop`；在基础设施仓库接入版本矩阵前，不连接 AWS 服务器。

## 记录 005：n8n AI 打标工作流基础配置

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`n8n-ai-tagging` 仓库
- 分支 / 提交：`feature/workflow-foundation` / `1315dc2`
- 目标：建立可版本化、可校验的 n8n AI 打标契约，为后续导入真实工作流做准备。
- 操作：
  - 增加 AI Gateway 环境变量模板和配置说明。
  - 固化 `Sol → Terra → Luna` 模型回退顺序。
  - 扩展 Tag Result JSON Schema，包含素材、媒体类型、标签结果和模型调用轨迹。
  - 明确 `unknown` 与 `not_applicable` 为可审计结果。
  - 增加示例结果、工作流契约文档和 JSON 校验脚本。
  - 更新 CI，使其执行统一校验脚本。
- 安全边界：没有写入真实 AI API Key、Directus Token 或 n8n Credential；工作流凭证仍由 n8n 管理。
- 验证：`bash scripts/validate.sh` 和 `git diff --check` 通过；功能分支已推送 GitHub。
- 后续：创建 PR 合并到 `develop`，再根据 Directus schema 定义真实 n8n workflow JSON。

## 记录 006：素材基础元数据服务契约

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`asset-metadata-service` 仓库
- 分支 / 提交：`feature/metadata-contract` / `c429be7`
- 目标：建立图片和视频固有信息的确定性提取契约，避免将尺寸、比例、时长等信息混入 AI Tag 或人工审核。
- 操作：
  - 增加图片/视频元数据 JSON Schema。
  - 增加宽高、约分比例、视频时长、帧率和确定性来源标记。
  - 扩展 Python 结果对象和构造函数，拒绝图片携带视频字段。
  - 增加元数据契约文档和单元测试。
  - 更新 CI 校验 JSON Schema。
- 安全边界：未连接 Directus、未读取服务器素材、未修改 AWS；服务只处理确定性元数据，不生成 AI 标签。
- 验证：Python 编译、内置 smoke validation、JSON 校验和 `git diff --check` 通过；本机缺少 pytest，因此完整 pytest 将由 CI 执行。
- Git：功能分支已推送至 GitHub。
- 后续：创建 PR 合并到 `develop`；之后设计 Directus 元数据字段映射和 ffprobe/ImageMagick 适配器。

## 记录 007：跨仓库接口契约对齐

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`directus-platform`、`n8n-ai-tagging`、`asset-metadata-service`
- 分支 / 提交：
  - Directus：`feature/staging-foundation` / `77d83ab`
  - n8n：`feature/workflow-foundation` / `cdeaa97`
  - Metadata：`feature/metadata-contract` / `1c425ad`
- 目标：统一 Directus 数据模型、元数据输出和 AI Tag 结果，避免后续工作流与审核界面各自定义字段。
- 操作：
  - 在 Directus 仓库增加 `DIRECTUS_DATA_MODEL.md`，定义元数据、标签定义、AI 提案、审核任务和版本快照集合。
  - n8n Tag Result 增加 `tag_definition_version` 和 `generated_at`。
  - 元数据结果增加 `asset_id`、`extractor_version` 和 `extracted_at`。
  - 明确元数据不可人工编辑、AI 提案不可覆盖、审核版本追加写入的约束。
- 安全边界：只修改契约文档、Schema 和本地测试；未连接 Directus、n8n 或 AWS，未触碰现有素材和数据库。
- 验证：JSON 校验、Python 编译、metadata smoke validation、n8n 校验脚本和 `git diff --check` 通过。
- Git：三个功能分支均已推送 GitHub，可分别创建 PR。
- 后续：审阅并合并三个 PR 后，再设计 Directus 数据模型快照和真实 n8n workflow。

## 记录 008：Directus Schema manifest

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`directus-platform` 仓库
- 分支 / 提交：`feature/schema-manifest` / `9b87f02`
- 目标：将 Directus 数据模型从说明文档推进为可审查、可校验的版本化 manifest。
- 操作：
  - 增加 `schema/manifest.v0.1.json`，定义元数据、标签定义、AI 提案、审核任务和审核版本集合。
  - 明确基础元数据字段只读、审核版本追加写入和标签库输入类型。
  - 增加 Schema 发布说明，规定先审查 manifest，再从干净 staging 导出 Directus snapshot。
  - 增加 manifest 校验脚本并接入 Directus CI。
- 安全边界：manifest 不包含真实密钥、用户数据或素材记录；未向远程 Directus 执行迁移。
- 验证：`bash scripts/validate-schema.sh` 和 `git diff --check` 通过；功能分支已推送 GitHub。
- 后续：创建 PR 合并到 `develop`；PR 审核通过后再在 staging 生成真正的 Directus snapshot。

## 记录 009：n8n 打标工作流骨架

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`n8n-ai-tagging` 仓库
- 分支 / 提交：`feature/workflow-foundation` / `c778edd`
- 目标：建立可审查的 Directus → 标签库 → AI Gateway → AI 提案工作流结构。
- 操作：
  - 增加禁用状态的 `asset-auto-tagging.v1.json`。
  - 包含素材读取、活动标签定义读取、媒体类型筛选、Sol 调用、结果规范化和不可变提案写回节点。
  - 工作流声明 Directus Schema 和 Tag Result 契约版本。
  - 将工作流 JSON 校验接入本地校验脚本。
- 安全边界：工作流保持 `active: false`；没有导入现有 n8n、没有配置真实 Credential、没有调用 AI Gateway 或 Directus。
- 验证：`bash scripts/validate.sh` 通过，工作流 JSON 和契约检查通过；功能分支已推送 GitHub。
- 后续：评审并补充 Terra/Luna 回退分支、Schema 校验节点和批量触发，再考虑导入 staging n8n。

## 记录 010：n8n 结果校验与模型回退策略

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`n8n-ai-tagging` 仓库
- 分支 / 提交：`feature/workflow-foundation` / `4558804`
- 目标：避免不完整或不符合契约的 AI 结果写入 Directus，并固化模型回退边界。
- 操作：
  - 在禁用工作流中增加 Asset/Tag Definitions 合并节点。
  - 增加 Tag Result 合同校验、有效性分支和拒绝无效结果节点。
  - 增加 `model-fallback.json`，固定 Sol → Terra → Luna 顺序和可回退错误类型。
  - 明确凭证错误、素材不存在和不支持媒体类型不触发模型回退。
- 安全边界：工作流仍为 `active: false`；未调用任何真实模型、Directus 或 n8n 实例。
- 验证：Tagging contract、Workflow skeleton、Model fallback policy 三项校验均通过。
- Git：功能分支已推送 GitHub。
- 后续：实现带错误输出的 Terra/Luna 分支，再进行 staging 导入前的人工审查。

## 记录 011：Sol / Terra / Luna 回退分支

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`n8n-ai-tagging` 仓库
- 分支 / 提交：`feature/workflow-foundation` / `85711fd`
- 目标：在工作流骨架中实现逐级模型回退，避免单一模型故障导致整个打标任务无反馈。
- 操作：
  - 为 Sol、Terra、Luna 增加独立调用和结果规范化节点。
  - 各模型调用启用错误输出，成功则进入统一 Tag Result 合同校验，失败才进入下一个模型。
  - 全部模型失败时保留失败轨迹，不写入 AI 提案。
  - 更新校验脚本，确认三个模型节点和合同校验节点存在。
- 安全边界：工作流仍为 `active: false`；未连接真实 AI Gateway、n8n 或 Directus。
- 验证：Tagging contract、Workflow skeleton、Model fallback policy 三项校验和 `git diff --check` 通过。
- Git：功能分支已推送 GitHub。
- 后续：导入前完成批量触发、错误分类和 staging 凭证审查。

## 记录 012：批量打标请求与 staging 导入预检

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：`n8n-ai-tagging` 仓库
- 分支 / 提交：`feature/workflow-foundation` / `231835d`
- 目标：支持单个或小批量素材触发，并在导入 staging n8n 前阻止不安全配置。
- 操作：
  - 增加 tagging request Schema，允许一个 `asset_id` 或 1-100 个唯一 `asset_ids`。
  - 工作流增加批量展开节点，每个素材仍独立进入读取、AI、校验和提案写回链路。
  - 增加 staging import preflight，检查工作流禁用状态、契约版本、凭证模板和潜在密钥。
  - 增加 staging 导入人工检查清单，要求先测单图、单视频、错误素材和小批量。
- 安全边界：工作流仍为 `active: false`；预检不连接 n8n、Directus 或 AI Gateway。
- 验证：Tagging、Workflow、Fallback、Batch Request、Staging Preflight 五项检查通过。
- Git：功能分支已提交；推送结果需以远端状态复核。
- 后续：先导入 staging n8n 但保持禁用，完成凭证绑定和最小样本测试后再评估启用。

## 记录 013：创建四仓库 PR

- 时间：2026-09-12
- 操作者：Codex / 用户确认
- 范围：四个 GitHub 仓库的功能分支
- 目标：将已验证的功能变更提交给 `develop` 分支评审，避免绕过分支规范直接部署。
- 操作：创建以下 Pull Request：
  - `directus-platform`：[PR #1](https://github.com/huey-huang/directus-platform/pull/1)
  - `n8n-ai-tagging`：[PR #1](https://github.com/huey-huang/n8n-ai-tagging/pull/1)
  - `asset-metadata-service`：[PR #1](https://github.com/huey-huang/asset-metadata-service/pull/1)
  - `infra-deployment`：[PR #1](https://github.com/huey-huang/infra-deployment/pull/1)
- 安全边界：只创建 PR，没有自动合并、没有部署 staging、没有修改 AWS 或 Directus 数据。
- 验证：只读检查显示四个 `develop` 仍是初始基线；PR 已创建供人工审阅。
- 后续：由用户审阅并合并 PR 到各自 `develop`；合并完成后再进行 staging 部署准备。

## 记录 014：PR 审阅合并与 staging 预发布版本矩阵

- 时间：2026-09-12
- 操作者：Codex / 用户明确授权
- 范围：四个 GitHub 仓库、`infra-deployment` staging 版本矩阵
- 操作：
  - 检查四个 PR 的目标分支、文件清单、CI 和 merge 状态。
  - 确认 CI 全部成功、状态为 CLEAN 后，以 squash 方式合并到各自 `develop`。
  - 删除已合并的远程功能分支，并同步四个本地 `develop`。
  - 为三个服务的 develop 合并提交创建统一 staging 预发布 Tag：`v0.1.1-rc.1`。
  - 将 staging 版本矩阵更新为三个预发布 Tag。
- 合并结果：
  - Directus：`ea404f5`
  - n8n：`f2a80a8`
  - Metadata：`7bb0020`
  - Infra：`fb58ab8`
- 安全边界：未自动合并到 `main`，未创建生产 Tag，未连接或修改 AWS/Directus/n8n。
- 验证：四个 PR 均为 MERGED；staging `validate.sh` 和 `deploy.sh staging` dry-run 通过。
- Git：版本矩阵功能分支：`feature/staging-release-candidate-pinning`，提交 `874a9d0`，已推送 GitHub。
- 后续：审阅并合并版本矩阵 PR；再进行测试服务器连接预检和 staging 导入准备。

## 记录 015：合并 staging 版本矩阵

- 时间：2026-09-12
- 操作者：Codex / 用户明确授权
- 范围：`infra-deployment` 仓库
- PR：[#2](https://github.com/huey-huang/infra-deployment/pull/2)
- 合并提交：`7269e48`
- 操作：
  - 检查 staging 版本矩阵 PR 的 CI，全部通过。
  - 以 squash 方式合并到 `develop`。
  - staging 现在固定引用 `v0.1.1-rc.1` 的三个服务版本。
- 安全边界：没有连接 AWS、没有执行远程部署、没有创建生产 Tag。
- 验证：PR 状态为 MERGED；staging dry-run 已通过。
- 后续：生成 staging 部署计划并执行服务器只读连接预检；在用户确认前不启用真实远程部署。

## 记录模板

```text
## 记录 NNN：简短标题

- 时间：YYYY-MM-DD HH:mm Asia/Shanghai
- 操作者：
- 范围：
- 分支 / 提交：
- 目标：
- 操作：
- 安全边界：
- 验证：
- 后续：
```
