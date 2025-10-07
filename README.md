# Capstone: ECS Fargate + ALB + RDS (Terraform + GitHub Actions OIDC)
![terraform](https://img.shields.io/badge/IaC-Terraform-844FBA) ![cicd](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF) ![aws](https://img.shields.io/badge/AWS-ECS%20%7C%20ALB%20%7C%20RDS-FF9900)

Production-style 3-tier on AWS:


Internet

│

ALB (HTTP :80) ← health checks /healthz

│ (targets)

ECS Fargate Service (Flask container from GHCR)

│ (TCP 5432, SG-locked)

RDS PostgreSQL (private subnets)

\## What’s included

\- \*\*Infrastructure\*\*: VPC (public/private), NAT, ALB, ECS Fargate, RDS Postgres, Security Groups, CloudWatch Logs, Secrets Manager.

\- \*\*IaC\*\*: Terraform with S3 remote state (optionally DynamoDB lock).

\- \*\*CI/CD\*\*: GitHub Actions with \*\*OIDC\*\* (no long-lived AWS keys).

&nbsp; - \*\*PR → Plan\*\*: fmt/validate/plan uploaded as artifact.

&nbsp; - \*\*Main → Apply\*\*: gated by \*\*Environment: production\*\* approval.

\## Requirements

\- AWS account (this was built in `us-east-1`)

\- Terraform ≥ 1.6

\- AWS CLI

\- GitHub repo with Actions enabled and an IAM role trusted via OIDC:

&nbsp; `arn:aws:iam::935271781612:role/GitHubActionsTerraformRole`

\## Layout

infra/

backend.hcl # S3 backend config

versions.tf # TF + provider versions, backend "s3"

providers.tf # aws provider + default tags

variables.tf # inputs (region, desired\_count, app\_image, etc.)

main.tf # VPC, SGs, ALB, ECS, RDS, Secrets, Logs

outputs.tf # alb\_dns\_name, db\_endpoint, db\_secret\_name

.github/workflows/

terraform.yml # plan on PR, apply on main (approval)

## App image

This deploys the container image built in a separate repo:
ghcr.io/simar-devops/docker-flask-sample:v0.1.4

Update `infra/variables.tf` → `app\_image` to roll out a new version.

\## How to run locally

```powershell

cd infra

terraform init -backend-config=backend.hcl

terraform plan -out=tfplan

terraform apply -auto-approve

CI/CD

Open a PR touching infra/\*\* → “Plan” job runs.

Merge to main → “Apply” waits for approval in Environments → production.

Verify

cd infra
terraform output -raw alb_dns_name   # copy to browser
# http://<ALB_DNS>/healthz  → 200 OK

Cost notes (important)

Biggest costs: RDS and NAT Gateway (ALB/Fargate are smaller).

To pause costs: see “Cost controls” below. Full stop: terraform destroy.

Cost controls

Scale ECS tasks: set desired_count in variables.tf (1 recommended).

Temporarily stop RDS (manual CLI): aws rds stop-db-instance --db-instance-identifier capstone-dev-pg

RDS non-Aurora can be stopped up to 7 days; ALB & NAT still incur cost while up.

Full clean-up: terraform destroy -auto-approve