# Directus staging Cloudflare R2 配置手册

> 环境：AWS staging
> Cloudflare Account ID：`83342bb7fa2fa080f266ed67870bd18d`
> Bucket：`velotric-assets-staging`
> S3 Endpoint：`https://83342bb7fa2fa080f266ed67870bd18d.r2.cloudflarestorage.com`
> 状态：Bucket 已创建，等待 R2 API Token 后启用 Directus R2

## 1. Cloudflare 后台操作

> 当前用于自动化的 Cloudflare Token 可以创建 R2 Bucket，但没有
> `Account API Tokens Read/Write` 权限，因此 R2 API Token 必须由你在控制台创建。

### 1.1 创建 Bucket

已完成：

```text
Dashboard -> R2 object storage -> Create bucket
Bucket name: velotric-assets-staging
Jurisdiction: default
Location: WNAM
```

不需要重复创建。

### 1.2 创建 R2 API Token

进入：

```text
Cloudflare Dashboard
-> R2 object storage
-> Overview
-> Manage R2 API Tokens
-> Create API Token
```

填写：

| 项目 | 值 |
| --- | --- |
| Token name | `directus-staging-r2` |
| Permissions | `Object Read & Write` |
| Bucket scope | 仅 `velotric-assets-staging` |
| TTL | 建议 90 天，或按公司策略 |

创建后立即复制并安全保存：

```text
Access Key ID
Secret Access Key
```

这两个值相当于 S3 的用户名和密码：

- 不提交 Git
- 不发送到聊天
- 不写入工作流 JSON
- 只写入服务器 `.env` 或 Secret Manager

### 1.3 可选：绑定素材访问域名

如果后续需要通过 CDN 访问素材：

```text
R2 -> velotric-assets-staging -> Settings -> Custom Domains
```

建议域名：

```text
assets-staging.velotric.co
```

如果域名在 Cloudflare，按控制台提示自动创建 CNAME。该自定义域名只用于公开或受控读取，不用于 Directus 的 S3 API 上传。

## 2. 在服务器配置 Directus R2

也可以使用仓库中的脚本 `directus-platform/scripts/configure-r2.sh`，它会隐藏输入
Access Key ID 和 Secret，并自动更新 `.env`、重建 Directus 和检查健康状态。

该脚本已部署到服务器：

```text
/opt/services/directus-staging-v011/scripts/configure-r2.sh
```

手动配置步骤如下。

登录服务器：

```bash
ssh -i "/Users/huey-velogo/.ssh/huangxiaoyi.pem" ubuntu@3.214.234.223
```

进入 Directus 目录：

```bash
cd /opt/services/directus-staging-v011
```

安全输入凭据，不要写入 Shell 历史：

```bash
read -s -p "R2 Access Key ID: " R2_ACCESS_KEY_ID
echo
read -s -p "R2 Secret Access Key: " R2_SECRET_ACCESS_KEY
echo
```

追加或更新 `.env`：

```text
STORAGE_LOCATIONS=r2,local
STORAGE_R2_DRIVER=s3
STORAGE_R2_KEY=<R2_ACCESS_KEY_ID>
STORAGE_R2_SECRET=<R2_SECRET_ACCESS_KEY>
STORAGE_R2_BUCKET=velotric-assets-staging
STORAGE_R2_REGION=auto
STORAGE_R2_ENDPOINT=https://83342bb7fa2fa080f266ed67870bd18d.r2.cloudflarestorage.com
STORAGE_R2_FORCE_PATH_STYLE=true
STORAGE_R2_ROOT=
```

说明：

- `STORAGE_LOCATIONS=r2,local` 将 R2 设为第一默认位置，同时保留 local 以读取旧文件。
- 现有本地文件不会自动迁移。
- `STORAGE_R2_ENDPOINT` 不包含 Bucket 名称。
- Secret 不要输出到终端或日志。

重建 Directus：

```bash
docker compose -f compose.yaml -f compose.staging.yaml up -d
```

检查：

```bash
docker compose -f compose.yaml -f compose.staging.yaml ps
curl -fsS http://127.0.0.1:8055/server/ping
```

预期：

```text
pong
```

## 3. 验证 R2 上传

在 Directus File Library 上传一个新文件，然后检查：

```text
directus_files.storage = r2
```

同时在 Cloudflare R2 Bucket 中应能看到对应对象。

建议先上传一张小图片，不要直接迁移全部素材。

## 4. 现有本地素材迁移

当前已有素材仍然在 Directus Docker Volume 中。迁移顺序：

1. 完成 R2 上传验证。
2. 备份 Directus PostgreSQL 和 uploads Volume。
3. 将本地对象复制到 R2，保持相对路径。
4. 校验对象数量和大小。
5. 在确认对象可读后，再更新 `directus_files.storage`。
6. 保留本地 Volume 至少一个备份周期。

不要在验证前删除本地 uploads。

## 5. 安全与限额

- 使用 Bucket 级 R2 Token，不要使用账户全权限 Token。
- Token 建议设置有效期并定期轮换。
- R2 Bucket 不需要公开写入权限。
- Directus 使用服务器端 S3 API 上传，不需要浏览器 CORS。
- 如果使用自定义域名公开读取，再单独配置 CORS、缓存和访问策略。
- 设置容量和费用告警，避免超出预算。

## 6. 当前状态

```text
R2 Bucket：已创建
R2 Token：待创建
Directus R2 环境变量：待写入
R2 上传验证：待执行
本地素材迁移：待执行
```
