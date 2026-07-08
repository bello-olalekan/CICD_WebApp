output "alb_dns_name" {
  description = "Public DNS name for the application load balancer."
  value       = aws_lb.app.dns_name
}

output "app_url" {
  description = "HTTP URL for the deployed application."
  value       = "http://${aws_lb.app.dns_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL where GitHub Actions pushes images."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name for GitHub Actions."
  value       = aws_ecs_cluster.app.name
}

output "ecs_service_name" {
  description = "ECS service name for GitHub Actions."
  value       = aws_ecs_service.app.name
}

output "ecs_task_execution_role_arn" {
  description = "Task execution role ARN for GitHub Actions variables."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "github_actions_role_arn" {
  description = "Role ARN to save as the GitHub Actions secret AWS_ROLE_TO_ASSUME."
  value       = aws_iam_role.github_actions.arn
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for GitHub Actions variables."
  value       = aws_cloudwatch_log_group.app.name
}
