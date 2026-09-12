# Environment configuration

The `*.env.example` files document non-secret deployment inputs only. Copy the
appropriate template into an external secret store or an ignored local file;
never commit the copy. Production values should be managed by GitHub
Environment secrets or AWS SSM/Secrets Manager.
