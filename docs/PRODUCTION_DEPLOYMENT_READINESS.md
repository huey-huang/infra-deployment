# Directus 正式环境部署准备清单

> 目标：在正式 AWS 环境部署 Directus、n8n 自动打标与 metadata-service
> 状态：准备清单，正式发布前需逐项确认
> 最后更新：2026-10-21

## 1. 正式环境目标架构

推荐保持 staging 的服务拆分和版本锁定方式：

```text
Cloudflare DNS / TLS
        |
        v
Caddy (仅 80/443)
        |
        +--> Directus 8055 (仅本机)
        +--> n8n 5678 (仅本机，按需域名)
        |
        +--> metadata-service 8080 (仅本机)

Directus PostgreSQL
n8n PostgreSQL
Cloudflare R2（可选，正式素材存储）
```

正式环境必须使用独立数据库、独立 Volume、独立 Secret 和独立域名，不能复用
staging 凭证。

## 2. 必须先确定的事项

| 事项 | 需要确认 | 建议 |
| --- | --- | --- |
| 正式域名 | Directus、n8n、素材 CDN 的域名 | `directus`、`n8n`、`assets` 等独立子域 |
| AWS 规格 | 实例类型、磁盘、带宽 | 至少 2C/8G；素材增长后评估 4C/16G |
| 存储方案 | 本地 Volume 或 R2 | 正式素材优先 R2，Directus 本地保留受控缓存 |
| 管理员身份 | 使用个人账号还是企业 SSO | 建议至少两个管理员，启用 MFA |
| 发布审批 | 谁批准 production 部署 | GitHub Environment + 人工 Approve |
| 备份 RPO/RTO | 可接受的数据丢失与恢复时间 | 至少每日备份 + 异地保存 |

## 3. AWS 与网络材料

需要准备：

- AWS 账号、Region、VPC、Subnet、Security Group。
- 正式 EC2 实例或 Elastic IP。
- SSH 管理方式：固定管理 IP、SSM Session Manager 或 VPN。
- IAM Role：EC2 访问 CloudWatch、S3/R2 备份所需的最小权限。
- 安全组入站规则：只开放 `22`（受限来源）、`80`、`443`。
- 安全组禁止公网访问 `5432`、`8055`、`5678`、`8080`。
- 域名 DNS 管理权限。
- Cloudflare API Token（如使用自动化 DNS/R2）。

## 4. 域名与证书材料

| 项目 | 示例 | 状态 |
| --- | --- | --- |
| Directus 域名 | `directus-prod.example.com` | 待确认 |
| n8n 域名 | `n8n-prod.example.com` | 按需 |
| 素材访问域名 | `assets.example.com` | 按需 |
| DNS 记录 | A/AAAA/CNAME | 待配置 |
| TLS 方式 | Caddy + Let's Encrypt | 推荐 |
| Cloudflare 代理模式 | DNS only / Proxied | 二选一，需固定 |

正式环境不要把 staging 域名直接切到 production，以免 Webhook、OAuth 回调和缓存混乱。

## 5. Secret 与凭证清单

以下内容必须在 production 重新生成或重新签发，不复制 staging 值：

| Secret | 用途 | 保存位置 |
| --- | --- | --- |
| Directus `SECRET` | 会话与签名 | AWS Secrets Manager / SSM |
| Directus PostgreSQL 密码 | 数据库 | Secrets Manager |
| Directus 管理员密码 | 初始管理员 | 密码管理器 |
| n8n PostgreSQL 密码 | n8n 数据库 | Secrets Manager |
| n8n `N8N_ENCRYPTION_KEY` | 凭证加密 | Secrets Manager，必须备份 |
| Directus 服务 Token | n8n 读取/写入 | n8n Credential |
| AI Gateway API Key | 模型调用 | n8n Credential |
| R2 Access Key / Secret | 对象存储 | Secrets Manager |
| Cloudflare API Token | DNS/R2 自动化 | Secrets Manager |
| SMTP 凭证 | 邮件通知 | Secrets Manager |

禁止：

- 把 Token、密码、PEM 写入 Git。
- 把 staging Token 带入 production。
- 在聊天、截图或工单中暴露完整 Secret。

## 6. 软件版本与仓库材料

正式发布应使用固定版本，不使用浮动 `latest`。

当前 staging 基线：

| 服务 | 当前版本 |
| --- | --- |
| Directus | `12.3.1` |
| n8n | `2.38.4` |
| PostgreSQL | `16.10-alpine` |
| metadata-service | 仓库 Tag |

正式发布前需要：

- `directus-platform` 合并到 `release/vX.Y.Z` 并打正式 Tag。
- `n8n-ai-tagging` 发布正式工作流版本。
- `asset-metadata-service` 发布正式镜像或固定 Tag。
- `infra-deployment` 更新 production 版本矩阵。
- 所有变更通过 PR 和 CI。
- 记录 commit SHA、镜像 digest 和 Tag。

## 7. 数据迁移材料

如果正式环境需要现有素材或标签：

- Directus 数据库逻辑备份（`pg_dump`）。
- Directus `uploads` 目录或 R2 对象清单。
- Directus Schema snapshot。
- 标签定义导出或初始化种子。
- 素材总数、总大小、目录结构校验值。
- 旧环境文件 ID 与新环境 ID 的映射策略（如需要）。
- 迁移演练记录和回滚点。

迁移前必须做恢复演练，不能只在正式切换当天第一次执行。

## 8. n8n 与 AI 打标材料

需要准备：

- AI Gateway Base URL。
- Sol / Terra / Luna 的实际模型 ID。
- staging 与 production 分离的 API Key。
- 请求超时、重试、限流和费用上限。
- Directus 服务账号和最小权限策略。
- n8n 工作流 JSON 的正式 Tag。
- 工作流保持禁用，测试通过后再启用。
- 失败告警接收人。

注意：工作流把 Directus 素材 URL 传给模型。正式环境应确认素材 URL 的访问方式，
优先使用短时签名 URL，避免公开文件或把长期 Token 暴露给第三方。

## 9. 存储与 CDN

如使用 Cloudflare R2：

- Bucket 名称、区域、访问域名。
- R2 API Token 或 S3 Access Key。
- Directus `STORAGE_LOCATIONS`、默认存储和 CORS 配置。
- 公共访问策略或签名 URL 策略。
- 缓存规则、缓存清除流程。
- 9G/10G 容量预警。
- 本地 Volume 与 R2 的一致性策略。

## 10. 备份、监控与运维

必须准备：

- PostgreSQL 每日备份，验证可恢复。
- Directus uploads/R2 备份策略。
- n8n 数据库与 encryption key 备份。
- 异地或跨账号备份。
- 磁盘、内存、容器健康、5xx、证书到期告警。
- CloudWatch 或 Uptime Kuma。
- 日志保留和轮转策略。
- 故障联系人和升级路径。

建议至少演练一次：

1. 数据库恢复到新目录；
2. 启动服务；
3. 验证管理员登录、素材读取、工作流执行；
4. 记录恢复耗时。

## 11. CI/CD 与发布材料

- GitHub repository 权限和分支保护。
- `develop`、`staging`、`release/*`、`main` 分支策略。
- GitHub Environments：staging、production。
- production 必须人工批准。
- SSH 私钥或部署凭证只放在 GitHub Secrets。
- 部署前备份、部署后健康检查。
- 回滚命令和上一版本镜像/Tag。

## 12. 正式上线验收清单

- [ ] DNS 解析正确，证书有效且自动续期。
- [ ] 公网只开放 22/80/443。
- [ ] Directus 管理员可登录，MFA/SSO 已评估。
- [ ] 5 个业务集合与关系正确。
- [ ] 标签定义数量和内容核对完成。
- [ ] 素材上传、读取、缩略图正常。
- [ ] n8n 工作流保持禁用时可通过手动触发测试。
- [ ] Sol/Terra/Luna 回退和错误处理验证通过。
- [ ] AI 提案写入 Directus 成功。
- [ ] 备份完成并完成一次恢复演练。
- [ ] 监控和告警能实际触发。
- [ ] 回滚流程在预发布环境演练通过。

## 13. 上线前需要业务方提供的最终材料

请业务/运维负责人逐项确认：

1. 正式域名和子域规划。
2. 正式 AWS 账号/Region/实例规格。
3. 正式 AI Gateway Base URL、模型 ID 和 production Key 的负责人。
4. 正式 Directus 管理员名单。
5. 是否启用企业 SSO/MFA。
6. R2 是否上线，Bucket 和访问域名。
7. 素材迁移范围和截止时间。
8. 备份保留周期和恢复目标。
9. production 发布审批人。
10. 上线窗口和回滚决策人。
