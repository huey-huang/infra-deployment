# infra-deployment

多环境部署和新服务器初始化仓库，只引用各服务版本，不复制业务代码或真实密钥。

当前版本：v0.1.0

环境配置位于 environments，真实 Secrets 由 AWS SSM/Secrets Manager 或 GitHub Environment 注入。

