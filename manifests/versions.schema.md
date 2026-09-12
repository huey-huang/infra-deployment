# Version manifest contract

`manifests/versions.yaml` is the single release input for a deployment. Every
value must be an immutable Git tag such as `v0.1.0` or the staging prerelease
`v0.1.1-rc.1`; moving branch names and `latest` are not allowed.

Required keys:

```yaml
directus_platform: vX.Y.Z
n8n_ai_tagging: vX.Y.Z
asset_metadata_service: vX.Y.Z
```

The deploy job validates the tag format before rendering a deployment. A
release is promoted by changing this file in a reviewed pull request, then
tagging the infrastructure commit. Production must use a stable tag without a
pre-release suffix.
