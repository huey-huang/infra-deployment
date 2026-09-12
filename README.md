# infra-deployment

多环境部署和新服务器初始化仓库。它只引用各服务的不可变版本，不复制业务代码、PEM、Token、数据库密码或生产数据。

## 仓库职责

- `bootstrap/`：新 Ubuntu 服务器的基础依赖初始化。
- `manifests/`：Directus、n8n 和元数据服务的版本矩阵。
- `environments/`：staging / production 配置模板；真实配置只能通过 Secret Store 或 GitHub Environment 注入。
- `scripts/`：校验、部署计划和健康检查。
- `.github/workflows/`：PR 校验、staging 流程和 production 手动流程。

## 分支和发布

推荐流程为 `feature/* → develop → staging → release/vX.Y.Z → main/tag`。修改版本矩阵必须经过 Pull Request；正式发布时给 infrastructure commit 打 tag，并由 production environment 的保护规则批准。

## 当前安全边界

`scripts/deploy.sh` 当前只生成 dry-run 计划，不连接远程服务器。真正的 SSH 或 AWS SSM 传输需要在明确密钥托管、审计和回滚策略后单独实现。

## 本地校验

```bash
bash scripts/validate.sh
bash scripts/deploy.sh staging
```

当前版本：v0.1.0
