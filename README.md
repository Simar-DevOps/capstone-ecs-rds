# Capstone: ECS Fargate + ALB + RDS (Terraform + GitHub Actions OIDC)

Production-style 3-tier on AWS:

- Internet  
- **ALB** (HTTP :80) ← health checks `/healthz`  
- **ECS Fargate Service** (Flask container from GHCR)  
- **RDS PostgreSQL** (private subnets, SG-locked)

## What’s included

- **Infrastructure:** VPC (public/private), NAT, ALB, ECS Fargate, RDS Postgres, Security Groups, CloudWatch Logs, Secrets Manager.
- **IaC:** Terraform with remote S3 state (optionally DynamoDB lock).
- **CI/CD:** GitHub Actions with **OIDC** (no long-lived AWS keys).
  - **PRs:** `fmt` → `validate` → `plan` (artifact upload; no apply).
  - **main:** gated **Apply** via GitHub **Environment** approval.

## Requirements

- AWS account (built/tested in `us-east-1`)
- Terraform ≥ **1.6**
- AWS CLI
- GitHub repo with Actions enabled and an IAM role trusted via OIDC  
  Example role name: `GitHubActionsTerraformRole`

## Layout

```
infra/
  backend.hcl      # S3 backend config
  versions.tf      # TF + provider versions, backend "s3"
  providers.tf     # aws provider + default tags
  variables.tf     # inputs (region, desired_count, app_image, etc.)
  main.tf          # VPC, SGs, ALB, ECS, RDS, Secrets, Logs
  outputs.tf       # alb_dns_name, db_endpoint, db_secret_name

.github/workflows/
  terraform.yml    # plan on PR, apply on main (approval)
```

## App image

The service uses a prebuilt image from a separate repo:  
`ghcr.io/simar-devops/docker-flask-sample:v0.1.4`

To roll out a new version, update **`infra/variables.tf` → `app_image`**.

## How to run locally (quick start)

```bash
cd infra
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform apply -auto-approve
```

### CI/CD flow

- Open a PR touching `infra/**` → CI runs **Plan** and uploads artifacts.
- Merge to **main** → **Apply** waits for approval in **Environments → production**.

### Verify

```bash
cd infra
terraform output -raw alb_dns_name   # copy to browser
# http://<ALB_DNS>/healthz  → 200 OK
```

## Cost notes (important)

- Biggest costs: **RDS** and **NAT Gateway** (ALB/Fargate are smaller).
- To pause costs: scale down `desired_count` in `variables.tf`; stop RDS (non-Aurora up to 7 days).
- Full clean-up: `terraform destroy -auto-approve`.
