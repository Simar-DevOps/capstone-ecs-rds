output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "Public ALB DNS"
}

output "db_endpoint" {
  value       = aws_db_instance.postgres.address
  description = "RDS endpoint"
}

output "db_secret_name" {
  value       = aws_secretsmanager_secret.db_creds.name
  description = "Secrets Manager secret"
}
