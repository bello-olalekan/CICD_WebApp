variable "aws_region" {
  description = "AWS region where the application infrastructure is deployed."
  type        = string
  default     = "us-east-1"
}

variable "github_repository" {
  description = "GitHub repository in owner/name format."
  type        = string
  default     = "bello-olalekan/CICD_WebApp"
}

variable "github_branch" {
  description = "Git branch allowed to assume the GitHub Actions OIDC role."
  type        = string
  default     = "main"
}

variable "github_environment" {
  description = "GitHub Actions environment allowed to assume the OIDC role."
  type        = string
  default     = "production"
}

variable "github_actions_role_name" {
  description = "IAM role assumed by GitHub Actions through OIDC."
  type        = string
  default     = "github-actions-cicd-webapp-role"
}

variable "ecr_repository_name" {
  description = "ECR repository name for the app image."
  type        = string
  default     = "cicd-webapp"
}

variable "ecs_cluster_name" {
  description = "ECS cluster name."
  type        = string
  default     = "sunny-eagle-8hn96b"
}

variable "ecs_service_name" {
  description = "ECS service name."
  type        = string
  default     = "cicd-webapp-service"
}

variable "ecs_task_family" {
  description = "ECS task definition family."
  type        = string
  default     = "cicd-webapp"
}

variable "ecs_task_execution_role_name" {
  description = "IAM role used by ECS tasks to pull from ECR and write logs."
  type        = string
  default     = "ecsTaskExecutionRole"
}

variable "log_group_name" {
  description = "CloudWatch log group used by the ECS task."
  type        = string
  default     = "/ecs/cicd-webapp"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 14
}

variable "alb_name" {
  description = "Application Load Balancer name."
  type        = string
  default     = "cicd-webapp-alb"
}

variable "target_group_name" {
  description = "ALB target group name."
  type        = string
  default     = "cicd-webapp-tg"
}

variable "alb_subnet_ids" {
  description = "Public subnet IDs attached to the ALB."
  type        = list(string)
  default = [
    "subnet-004afc8a0f89f73cf",
    "subnet-07e63dc2d16c5915d",
    "subnet-0d74ed82e115cac7a"
  ]
}

variable "alb_security_group_name" {
  description = "Security group name for the ALB."
  type        = string
  default     = "cicd-webapp-alb-sg"
}

variable "alb_security_group_description" {
  description = "Security group description for the ALB. This must match imported security groups because AWS forces replacement when descriptions change."
  type        = string
  default     = "CICD_Web_App_SG"
}

variable "ecs_task_security_group_name" {
  description = "Security group name for ECS tasks."
  type        = string
  default     = "cicd-webapp-task-sg"
}

variable "ecs_task_security_group_description" {
  description = "Security group description for ECS tasks. This must match imported security groups because AWS forces replacement when descriptions change."
  type        = string
  default     = "cicd-webapp"
}

variable "container_name" {
  description = "Container name in the ECS task definition."
  type        = string
  default     = "web"
}

variable "container_port" {
  description = "Port exposed by the container."
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "ALB target group health check path."
  type        = string
  default     = "/api/status"
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Fargate task memory."
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of ECS tasks to run."
  type        = number
  default     = 1
}

variable "initial_image_tag" {
  description = "Image tag used by Terraform for the initial task definition. GitHub Actions deploys commit-specific revisions afterward."
  type        = string
  default     = "latest"
}
