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
