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

## 记录 016：测试服务器只读预检

- 时间：2026-09-12
- 操作者：Codex / 用户明确授权
- 范围：AWS staging 测试服务器 `3.214.234.223`
- 目标：确认服务器具备新 staging 部署的基础条件，但不执行任何远程变更。
- 检查结果：
  - Ubuntu 24.04.4 LTS，SSH 登录成功。
  - Docker 29.8.0，Docker Compose v5.5.1。
  - Docker systemd 服务 active，`ubuntu` 用户属于 docker 组。
  - 根分区约 89G 可用，内存约 7.6GiB，总体资源充足。
  - `/opt/services/directus-test` 存在，保留旧 `.env`、配置、备份和扩展目录。
  - 当前没有运行中的容器。
- 安全边界：只执行远程只读命令；未读取 Secret 内容，未启动、停止、删除或修改容器、Volume、文件和 DNS。
- 验证：SSH、Docker、资源和部署目录检查均通过。
- 后续：先准备新部署目录和 Secret 注入方案；真正执行前还需用户确认远程写入范围。

## 记录 017：Directus staging 首次部署

- 时间：2026-09-12
- 操作者：Codex / 用户明确授权
- 范围：AWS 测试服务器 `/opt/services/directus-staging-v011`
- 版本：`directus-platform v0.1.1-rc.1`
- 操作：
  - 发现服务器无法匿名 clone 私有 GitHub 仓库，改用本地已验证 Tag 归档通过 SSH 传输，不写入 Git 凭证。
  - 创建全新 staging 目录，复用旧目录 `.env` 的受限副本，并补充固定的 `POSTGRES_VERSION` 与 `DIRECTUS_VERSION` 非敏感版本变量。
  - 拉取 `directus/directus:12.3.1` 和 `postgres:16.10-alpine`。
  - 启动 Directus 和 PostgreSQL，创建独立 staging Volume 和网络。
- 验证：PostgreSQL healthy；Directus healthy；本机访问 `https://directus.velotric.co/server/ping` 返回 `pong`。
- 安全边界：未修改旧 `/opt/services/directus-test`、旧 Volume 或 Caddy；未部署 n8n/元数据服务；未导入 Schema snapshot；未输出 Secret 值。
- 后续：为 n8n 和 metadata service 增加可运行容器定义后，再部署到独立 staging 服务；Directus Schema snapshot 需单独审查后导入。

## 记录 018：n8n 与 metadata staging 运行时部署

- 时间：2026-09-12
- 操作者：Codex / 用户明确授权
- 范围：AWS 测试服务器
- 版本：n8n `v0.1.2-rc.1`，metadata `v0.1.2-rc.1`
- 操作：
  - 将本地已验证 Tag 归档通过 SSH 传输，避免服务器保存 GitHub 凭证。
  - 部署 n8n 运行时到 `/opt/services/n8n-staging-v012`，包含独立 PostgreSQL 和 n8n Volume。
  - 部署 metadata HTTP 服务到 `/opt/services/metadata-staging-v012`，构建 Python 镜像并启动容器。
  - n8n 工作流文件以只读方式挂载，但没有自动导入或启用。
  - 修正 infra staging 模板，记录 Directus、n8n、metadata 三个独立部署路径。
- 验证：n8n healthy；metadata healthy；`/healthz` 返回成功；metadata 图片示例返回 `16:9` 和确定性来源信息；Directus 仍 healthy。
- 安全边界：未导入 n8n workflow、未配置真实 AI Credential、未调用 AI、未修改 Caddy/DNS/旧部署目录。
- 后续：为 n8n 绑定 staging Credential 并导入工作流（保持禁用），再设计 metadata 到 Directus 的受限写回任务。

## 记录 019：Directus staging Schema 落地

- 时间：2026-09-12
- 操作者：Codex / 用户明确授权
- 范围：新 staging Directus 数据库
- 操作：通过 Directus HTTP API 幂等创建已审阅的 5 个业务集合：`asset_metadata`、`asset_tag_definitions`、`asset_tag_ai_proposals`、`asset_tag_reviews`、`asset_tag_review_versions`，并创建对应字段。
- 约束：`asset_metadata` 固有字段标记为只读；AI 提案和审核版本以独立集合保存。
- 验证：API 返回所有集合创建完成；未写入任何素材记录、标签记录或真实业务数据。
- 安全边界：只作用于新 staging 数据库；旧 `/opt/services/directus-test` 和旧 Volume 未触碰。
- 后续：从 staging 导出正式 Directus snapshot，经过 PR 审核后纳入版本控制。

## 记录 020：n8n staging 工作流导入

- 时间：2026-09-12
- 操作者：Codex / 用户明确授权
- 范围：新 staging n8n 数据库
- 操作：首次导入因导出 JSON 缺少 n8n workflow `id` 失败；在仓库补充稳定 `id`、`versionId` 等导入元数据，创建并合并 n8n PR #3，发布 `v0.1.3-rc.1`，随后重新导入成功。
- 结果：工作流 `asset-auto-tagging-v1-staging` 已存在。
- 安全边界：工作流保持 `active: false`；未绑定真实 Credential、未调用 AI、未执行自动打标。
- 验证：n8n CLI 报告 `Successfully imported 1 workflow`，工作流列表可见。
- 后续：在 n8n UI 中绑定 staging Credential，先手动测试且保持禁用，再考虑启用。

## 记录 023：n8n staging 运行时变量配置

- 时间：2026-09-12
- 操作者：Codex / 用户明确授权
- 范围：AWS `/opt/services/n8n-staging-v012`
- 版本：`n8n-ai-tagging v0.1.4-rc.1`
- 操作：发布 n8n 运行时环境变量契约，区分非敏感路由变量和 n8n Credential；在 staging 注入 Directus 地址 `https://directus.velotric.co` 及 Sol/Terra/Luna 模型顺序；重建 n8n 容器。
- 验证：n8n `/healthz` 返回 `{"status":"ok"}`，容器 healthy。
- 安全边界：未写入 AI Gateway URL/API Key、Directus Token；工作流仍为禁用状态；未调用 AI。
- 后续：用户在 n8n UI 创建并绑定 staging-only Directus 和 AI Gateway Credential。

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

## 记录 024：staging 三服务健康检查与日志 PR 合并

- 时间：2026-09-12  Asia/Shanghai
- 操作者：Codex / 用户明确授权
- 范围：`infra-deployment` 操作日志、AWS staging 测试服务器
- 分支 / 提交：日志分支 `feature/operation-log-022` rebase 后提交 `f128e3c`；PR #11 已通过 CI 并 squash 合并到 `develop`
- 目标：确认运行时部署结果，并在继续配置凭证前建立可追溯记录。
- 操作：解决 `docs/OPERATION_LOG.md` 与最新 `develop` 基线的冲突；推送并合并 PR #11；通过 SSH 对 Directus、n8n、metadata 容器及 HTTP 健康端点执行只读检查。
- 安全边界：仅访问 staging；未启用 n8n 工作流；未导入 AI/API 凭证；未修改生产环境、旧 `/opt/services/directus-test`、DNS 或 Cloudflare 配置。
- 验证：Directus 容器 healthy，`https://directus.velotric.co/server/ping` 返回 `pong`；n8n 容器 healthy，`127.0.0.1:5678/healthz` 返回 `{"status":"ok"}`；metadata 容器 healthy，`127.0.0.1:8080/healthz` 返回 `{"status":"ok"}`。
- 后续：在 n8n UI 创建 staging-only Directus 与 AI Gateway Credential，绑定到工作流但保持禁用，先执行单图片、单视频和错误 asset ID 的手动测试。

## 记录 025：n8n 出站链路预检

- 时间：2026-09-12 15:20 Asia/Shanghai
- 操作者：Codex / 用户明确授权
- 范围：AWS staging Docker 网络
- 目标：在绑定凭证前确认 n8n 对 Directus 及后续 metadata 服务的连通性。
- 操作：从 n8n 容器内只读请求 Directus `/server/ping`，并检查 n8n 与 metadata 容器所属 Docker 网络。
- 验证：Directus 返回 `pong`；n8n 与 metadata 当前分别位于 `n8n-ai-tagging_*` 和 `asset-metadata-service_default` 网络，容器 DNS 不能直接解析对方。
- 影响评估：当前工作流只读取 Directus、调用 AI Gateway 并写回 Directus，未调用 metadata，因此不阻塞凭证绑定和手动打标测试。
- 安全边界：未修改 Docker 网络、服务配置、凭证或业务数据。
- 后续：在 metadata 接入工作流前，通过 infra-deployment 变更将两个服务接入受控共享网络，并补充连通性测试。

## 记录 026：确认 Directus 域名绑定

- 时间：2026-09-12 15:50 Asia/Shanghai
- 操作者：Codex / 用户明确授权
- 范围：AWS staging Directus、Cloudflare DNS 只读核验
- 目标：确认截图中的 `directus.velotric.co` A 记录是否已绑定当前 staging Directus。
- 操作：查询 `directus.velotric.co` A 记录；请求 HTTPS 健康端点；读取并校验服务器 Caddy 配置。
- 验证：A 记录解析到 `3.214.234.223`；`https://directus.velotric.co/server/ping` 返回 HTTP 200 和 `pong`；Caddy 将域名反向代理到 `127.0.0.1:8055`，配置校验通过。
- 安全边界：本次未修改 Cloudflare DNS、Caddy、服务器或 Directus 配置。
- 结论：当前域名已经绑定并可访问新 staging Directus，无需重复创建该 DNS 记录。
- 后续：如需域名访问 n8n 或 metadata，应分别规划子域名和反代配置；当前 n8n/metadata 仍只监听本机端口。

## 记录 027：n8n Directus Header Auth 兼容修复部署

- 时间：2026-09-14 Asia/Shanghai
- 操作者：Codex / 用户明确授权
- 范围：`n8n-ai-tagging` staging 工作流
- 版本：`v0.1.5-rc.1`，PR #5 已合并
- 操作：将三个 Directus HTTP 节点从不存在的 `directusApi` 预定义类型改为 `genericCredentialType` + `httpHeaderAuth`；同步更新 staging 工作流并使用 `--updateExisting` 导入。
- 验证：工作流 `asset-auto-tagging-v1-staging` 导入成功，仍为 `active: false`；三个 Directus 节点均为 Header Auth；n8n `/healthz` 返回成功。
- 安全边界：未写入或导出任何 Token/API Key；未启用工作流；未修改生产环境。
- 后续：用户在三个 Directus 节点中选择已有 `directus-staging` 凭证；AI Gateway 凭证绑定后，再执行单图、单视频和错误 asset ID 测试。

## 记录 028：绑定 Directus 凭证并初始化标签库

- 时间：2026-10-20 11:30 Asia/Shanghai
- 操作者：Codex / 用户明确授权
- 范围：AWS staging n8n、staging Directus、`infra-deployment` 版本矩阵
- 分支 / 提交：
  - 版本矩阵：`feature/staging-version-matrix-n8n-015`，PR #17 已合并
  - 操作日志：`feature/operation-log-028`
- 目标：把已经创建好的 Directus 凭证接入工作流，并恢复标签定义数据。
- 操作：
  - 将 `manifests/versions.yaml` 中的 n8n 版本从 `v0.1.2-rc.1` 修正为实际部署的 `v0.1.5-rc.1`。
  - 通过 n8n CLI 导出工作流，仅为 `load-asset`、`load-tags`、`write-proposal` 三个节点写入 `directus-staging` 的凭证引用（内部 ID + 名称），再以 `--updateExisting` 导入。
  - 从既有标签需求脚本生成 12 个业务维度、80 个选项，排除素材类型、视频时长、视频比例三个技术维度；写入 `asset_tag_definitions`。
  - `atmosphere` 维度当前没有标准选项，因此标记为 `active=false`，待业务补充选项后再启用。
- 验证：
  - 工作流仍为 `active: false`。
  - 三个 Directus 节点已绑定 `httpHeaderAuth`；Sol/Terra/Luna 三个 AI 节点仍未绑定。
  - 标签定义共 12 条：common 10（启用 9）、image 1、video 1。
- 安全边界：未读取或输出任何 Token/API Key；未启用工作流；未修改生产环境。
- 已知问题：`.env` 中的初始管理员密码已被人工重置，Directus API 登录返回 401；因此标签初始化改为直接使用幂等 SQL 写入 staging 数据库，未改动管理员密码。
- 后续：
  - 用户创建 `ai-gateway-staging` Header Auth 凭证后，绑定三个 AI 节点。
  - 上传 1 张图片和 1 个视频作为测试素材，再执行首次手动打标测试。

## 记录 029：新 EC2 实例完整重建 staging

- 时间：2026-10-21 14:30–15:10 Asia/Shanghai
- 操作者：Codex / 用户明确授权
- 范围：AWS `us-east-1` 新 EC2 实例 `3.214.234.223`
- 目标：原实例删除后，按既有 staging 手册在新实例重新部署完整环境。
- 操作：
  - 确认新实例复用了原公网 IP，SSH 主机指纹变化；备份并从 `known_hosts` 移除旧指纹后重新信任新 ED25519 指纹 `SHA256:UQ8ODG/w0epx+oeevrrd4MNzxtCjt8Jo+37RhLx/0b4`。
  - 安装 Docker Engine `29.9.2`、Buildx `0.38.1`、Compose `v5.6.0`，启用 Docker 日志轮转。
  - 部署 Directus `12.3.1` 与 PostgreSQL `16.10-alpine` 到 `/opt/services/directus-staging-v011`。
  - 部署 n8n `2.38.4` 与独立 PostgreSQL `16.10-alpine` 到 `/opt/services/n8n-staging-v012`。
  - 构建并部署 metadata-service 到 `/opt/services/metadata-staging-v012`。
  - 安装 Caddy `2.6.2` 并配置 `directus.velotric.co -> 127.0.0.1:8055`。
  - 应用 `directus-schema-v0.1`：创建 `asset_metadata`、`asset_tag_definitions`、`asset_tag_ai_proposals`、`asset_tag_reviews`、`asset_tag_review_versions` 及 6 个关系。
  - 导入 12 个标签维度、80 个选项；`atmosphere` 因无标准选项保持未启用。
  - 创建 Directus 服务账号 `n8n-staging@velotric.co`、最小权限策略和静态 Token；Token 仅保存在服务器 `.secrets/n8n-directus-token`（权限 600）。
  - 通过 n8n CLI 导入 `directus-staging` 凭证并绑定 `load-asset`、`load-tags`、`write-proposal`；临时明文文件导入后立即删除。
  - 导入 `asset-auto-tagging-v1-staging` 工作流，保持 `active: false`。
- 验证：
  - 五个容器全部 healthy。
  - Directus `/server/ping` 返回 `pong`；n8n `/healthz` 与 metadata `/healthz` 返回 `{"status":"ok"}`。
  - 服务 Token 访问 `asset_tag_definitions` 和 `files` 均为 HTTP 200。
  - 工作流仍为禁用；三个 Directus 节点已绑定，三个 AI 节点未绑定。
  - 标签统计：common 10（启用 9）、image 1、video 1。
- 安全边界：未输出任何密码、Token 或 API Key；未启用工作流；未修改生产环境。
- 阻塞项：
  - 新实例安全组仅放行 `22`，`80/443` 从公网不可达，Let's Encrypt HTTP-01/TLS-ALPN 验证超时，HTTPS 尚未生效。
  - AI Gateway Base URL 和 API Key 尚未提供。
- 数据说明：原实例的数据与备份未做异地保存，新环境素材数为 0，未恢复旧数据。
- 后续：放行安全组 80/443 后验证证书；在 n8n 创建 `ai-gateway-staging` 并绑定三个模型节点；上传测试素材后执行端到端测试。

## 记录 030：Directus 公网域名与 HTTPS 绑定完成

- 时间：2026-10-21 10:26 Asia/Shanghai
- 操作者：用户放行安全组 / Codex 验证与配置
- 范围：AWS staging、Cloudflare DNS、Caddy、Directus
- 操作：
  - 用户将安全组入站规则放行 `80` 和 `443`。
  - 确认公网 80/443 可达。
  - Caddy 原 ACME 重试已进入 3 小时退避，且 ZeroSSL legacy 账号失效；将 ACME 固定到 Let's Encrypt，并配置联系邮箱 `admin@velotric.co`。
  - 重启 Caddy，立即重试 TLS-ALPN-01 验证并成功签发证书。
- 验证：
  - `https://directus.velotric.co/server/ping` 返回 HTTP 200 和 `pong`。
  - `http://directus.velotric.co/server/ping` 返回 308 跳转到 HTTPS。
  - `https://directus.velotric.co/admin/login` 返回 HTTP 200。
  - 证书 CN 为 `directus.velotric.co`，签发者为 Let's Encrypt，有效期至 2027-01-19。
- 安全边界：Directus 仍仅监听 `127.0.0.1:8055`；公网只开放 22/80/443；未修改生产环境。
- 后续：更新 SSH 22 来源为固定管理 IP；完成 AI Gateway 凭证和端到端打标测试。

## 记录 031：Directus 驱动打标闭环与 R2 Bucket 创建

- 时间：2026-10-22 Asia/Shanghai
- 操作者：Codex / 用户明确授权
- 范围：Directus staging、n8n staging、Cloudflare R2
- 目标：从 Directus 发起任务完成图片打标，并开始 R2 存储接入。
- 操作：
  - 创建 `staging-shared` Docker 网络，将 Directus 与 n8n 接入同一网络。
  - 创建 `tagging_jobs` 集合和 Directus 事件 Flow，新增 queued 任务时调用 n8n Webhook。
  - 创建 `directus-flow-staging` Header Auth 凭证并启用 n8n Webhook。
  - 将工作流改为通过 `getBinaryDataBuffer` 读取 n8n `filesystem-v2` Binary，再生成 Base64 data URL。
  - 将 AI 调用切换到已验证的 `/v1/responses` 接口，强化标签提示词并要求每个标签定义均返回，空标签触发回退。
  - 在 Cloudflare 创建 R2 Bucket `velotric-assets-staging`。
- 验证：
  - Directus 创建 `tagging_jobs` 后自动进入 `processing`，最终进入 `review`。
  - 任务 `5c1fe07b-3e25-4560-9b38-081c8e809059` 成功，模型 `gpt-5.6-sol`。
  - Proposal `66e24472-5ee2-403c-8a17-a4f2f0a2223d` 写入 10 个标签，包含 `riding_scenario=beach`、`product_color=classic_scarlet`、`scene=outdoor`、`image_type=lifestyle`、`accessories=rear_rack` 等。
  - 标签结果通过 `tag-result-v1` 校验。
- 安全边界：未启用生产环境；未迁移现有本地素材；R2 Token 尚未创建。
- 后续：创建 Bucket 级 R2 Token，写入 Directus staging `.env`，验证新上传文件 `storage=r2`，再规划历史素材迁移。

## 记录 032：Cloudflare R2 staging 存储验证完成

- 时间：2026-10-23 Asia/Shanghai
- 操作者：用户创建 R2 Token / Codex 验证与修复
- 范围：Directus staging、Cloudflare R2
- 操作：
  - 用户在 Cloudflare 创建 `velotric-assets-staging` Bucket 的 Bucket 级 R2 Token。
  - 用户在服务器运行 `scripts/configure-r2.sh`，写入 R2 配置并重建 Directus。
  - 发现 Directus `compose.yaml` 未透传 `STORAGE_*`，补充 R2 环境变量映射后重建容器。
- 验证：
  - Directus 容器已加载 `STORAGE_LOCATIONS=r2,local`、`STORAGE_R2_BUCKET=velotric-assets-staging`、`STORAGE_R2_DRIVER=s3`。
  - 上传测试文件 `335f618c-a51f-4bdd-a240-e7a8f030b384`，返回 `storage=r2`。
  - 从 Directus 读取该 R2 素材返回 HTTP 200。
  - 删除该素材返回 HTTP 204。
  - 测试文件已清理，Bucket 恢复为空。
- 安全边界：R2 凭据仅存在于服务器 `.env`，未写入 Git 或日志；未迁移现有本地素材。
- 后续：规划历史本地素材到 R2 的迁移、对象校验和 `directus_files.storage` 更新。
