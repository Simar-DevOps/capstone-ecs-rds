# Contributing

- **Branching:** `feature/*`, `fix/*`, `chore/*`
- **Commits:** Conventional Commits (e.g., `feat: add rds snapshot example`)
- **PRs:** Keep them small. Use the PR template. Include risk & rollback.

## Local checks
- **Terraform:** `terraform fmt -recursive`, `terraform validate`, `terraform plan -var-file=dev.tfvars` (or your env file)
- **CI/CD:** Plans run on PR. `main` apply is gated via the protected **production** environment.

## Notes
- No long-lived AWS keys in CI. We use GitHub **OIDC** → an AWS IAM role.
