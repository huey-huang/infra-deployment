# Directus staging 域名绑定 Runbook

> 适用环境：AWS staging，`directus.velotric.co`
> 最后更新：2026-10-21

## 1. 当前状态

| 项目 | 当前值 |
| --- | --- |
| 公网 IP | `3.214.234.223` |
| Directus 本机端口 | `127.0.0.1:8055` |
| Caddy | 已安装并运行，监听 `80/443` |
| DNS A 记录 | `directus.velotric.co -> 3.214.234.223` |
| Cloudflare 代理 | DNS only |
| 公网 22 | 可达 |
| 公网 80/443 | **当前不可达，安全组未放行** |
| HTTPS | 尚未完成证书签发 |

当前唯一阻塞项是 AWS 安全组。DNS 和 Caddy 配置已经就绪。

## 2. 放行 AWS 安全组

在 AWS Console 进入：

```text
EC2 -> Instances -> 选中新 staging 实例 -> Security -> Security groups
```

编辑该实例绑定的安全组，添加入站规则：

| Type | Protocol | Port | Source | 说明 |
| --- | --- | --- | --- | --- |
| HTTP | TCP | 80 | `0.0.0.0/0` | Let's Encrypt HTTP-01 与 HTTP 跳转 |
| HTTPS | TCP | 443 | `0.0.0.0/0` | Directus 管理后台和 API |

如果使用 IPv6，再添加 `::/0` 对应规则。

不要放行：

```text
8055
5678
8080
5432
```

这些端口应继续只监听 `127.0.0.1` 或 Docker 内部网络。

## 3. 确认 DNS

DNS 已正确指向新实例，无需重复创建。可在本地检查：

```bash
dig +short directus.velotric.co A
```

期望输出：

```text
3.214.234.223
```

如果 Cloudflare 中使用代理模式，需要确保 SSL/TLS 模式为 `Full (strict)`；当前使用
`DNS only`，由 Caddy 直接申请 Let's Encrypt 证书，配置更简单。

## 4. 确认 Caddy 与证书

安全组放行后，Caddy 会自动重试 ACME 验证，通常 1 分钟内完成。

在服务器上检查：

```bash
sudo systemctl status caddy --no-pager
sudo journalctl -u caddy --no-pager -n 50
sudo caddy validate --config /etc/caddy/Caddyfile
```

查看证书是否已签发：

```bash
echo | openssl s_client \
  -servername directus.velotric.co \
  -connect directus.velotric.co:443 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
```

## 5. 验证公网访问

在本地执行：

```bash
curl -i https://directus.velotric.co/server/ping
```

期望：

```text
HTTP/2 200
pong
```

然后打开：

[https://directus.velotric.co/admin](https://directus.velotric.co/admin)

Directus 的 `PUBLIC_URL` 已设置为：

```text
PUBLIC_URL=https://directus.velotric.co
```

无需再次修改 `.env` 或重建容器。

## 6. 可选：绑定 n8n staging 域名

当前 n8n 仍只通过 SSH 隧道访问。若希望浏览器直接访问，可使用：

```text
n8n-staging.velotric.co
```

需要完成四项：

1. Cloudflare 添加 A 记录：

```text
n8n-staging.velotric.co -> 3.214.234.223
```

2. Caddy 增加 vhost：

```caddyfile
n8n-staging.velotric.co {
    encode zstd gzip
    reverse_proxy 127.0.0.1:5678
}
```

3. 更新 `/opt/services/n8n-staging-v012/.env.runtime`：

```text
N8N_HOST=n8n-staging.velotric.co
N8N_PROTOCOL=https
N8N_EDITOR_BASE_URL=https://n8n-staging.velotric.co
N8N_WEBHOOK_URL=https://n8n-staging.velotric.co/
N8N_SECURE_COOKIE=true
```

4. 重建 n8n 容器：

```bash
cd /opt/services/n8n-staging-v012
docker compose --env-file .env.runtime up -d
```

绑定域名后建议使用 Cloudflare Access 或 IP 白名单保护 n8n 管理后台；Webhook
路径需要单独的访问策略，不能简单要求人工登录。

## 7. 故障排查

| 现象 | 优先检查 |
| --- | --- |
| 80/443 超时 | AWS 安全组入站规则 |
| `connection refused` | Caddy 是否运行、80/443 是否监听 |
| ACME HTTP-01 超时 | 安全组、DNS 指向、Cloudflare 代理 |
| ACME 返回 404 | Caddy vhost 域名是否与 DNS 完全一致 |
| 证书正常但页面 502 | Directus 容器是否 healthy、8055 是否监听 |
| 管理后台跳转到错误地址 | Directus `PUBLIC_URL` |

## 8. 回滚

域名层回滚只需：

1. 恢复 Cloudflare A 记录到旧目标；
2. 将 Caddy vhost 改回旧后端；
3. `sudo systemctl reload caddy`。

不要把 `docker compose down --volumes` 作为域名回滚手段。
