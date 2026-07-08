# Terraform Infrastructure

This folder defines the AWS infrastructure for the CICD_WebApp deployment:

- ECR repository
- CloudWatch log group
- ECS cluster
- ECS task execution role
- GitHub Actions OIDC deploy role
- Application Load Balancer
- ALB target group and listener
- ECS Fargate service
- Security groups for the ALB and ECS tasks

The GitHub Actions workflow still builds and deploys new task definition revisions. Terraform owns the long-lived infrastructure around it.

## Prerequisites

- Terraform `>= 1.5`
- AWS CLI credentials with permission to manage IAM, ECS, ECR, EC2, ELB, and CloudWatch Logs
- Existing GitHub OIDC provider in AWS:

```text
https://token.actions.githubusercontent.com
```

## First-Time Setup

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then initialize Terraform:

```bash
terraform init
```

## If Resources Already Exist

This project already has some manually-created AWS resources. Import them before running `terraform apply`, otherwise Terraform will try to create resources with names that AWS already has.

You can import the known resources with the helper script:

```bash
./import-existing.sh
```

The script uses these defaults:

```text
AWS_REGION=us-east-1
ECR_REPOSITORY_NAME=cicd-webapp
LOG_GROUP_NAME=/ecs/cicd-webapp
ECS_CLUSTER_NAME=sunny-eagle-8hn96b
ECS_SERVICE_NAME=cicd-webapp-service
ECS_TASK_EXECUTION_ROLE_NAME=ecsTaskExecutionRole
GITHUB_ACTIONS_ROLE_NAME=github-actions-cicd-webapp-role
ECS_TASK_SECURITY_GROUP_NAME=cicd-webapp-task-sg
ALB_SECURITY_GROUP_NAME=cicd-webapp-alb-sg
ALB_NAME=cicd-webapp-alb
TARGET_GROUP_NAME=cicd-webapp-tg
```

You can override any value before running it:

```bash
AWS_REGION=us-east-1 ALB_NAME=my-alb ./import-existing.sh
```

Or run imports manually from inside the `terraform/` folder:

```bash
terraform import aws_ecr_repository.app cicd-webapp
terraform import aws_cloudwatch_log_group.app /ecs/cicd-webapp
terraform import aws_ecs_cluster.app sunny-eagle-8hn96b
terraform import aws_iam_role.ecs_task_execution ecsTaskExecutionRole
terraform import aws_iam_role.github_actions github-actions-cicd-webapp-role
terraform import aws_security_group.ecs_tasks sg-03cae80e9a01251a9
```

If you already created the ALB, ALB security group, target group, listener, or ECS service manually, import those too:

```bash
terraform import aws_security_group.alb ALB_SECURITY_GROUP_ID
terraform import aws_lb.app ALB_ARN
terraform import aws_lb_target_group.app TARGET_GROUP_ARN
terraform import aws_lb_listener.http LISTENER_ARN
terraform import aws_ecs_service.app sunny-eagle-8hn96b/cicd-webapp-service
```

You can find those IDs and ARNs in the AWS Console.

## Plan And Apply

Preview changes:

```bash
terraform plan
```

Apply changes:

```bash
terraform apply
```

After apply, Terraform prints values that map directly to GitHub Actions settings.

## GitHub Actions Values

Save this output as the GitHub secret:

```text
AWS_ROLE_TO_ASSUME = github_actions_role_arn
```

Save these outputs as GitHub variables:

```text
AWS_REGION = us-east-1
ECR_REPOSITORY = cicd-webapp
ECS_CLUSTER = ecs_cluster_name
ECS_SERVICE = ecs_service_name
ECS_TASK_FAMILY = cicd-webapp
ECS_TASK_EXECUTION_ROLE_ARN = ecs_task_execution_role_arn
AWS_LOG_GROUP = cloudwatch_log_group_name
```

## Important Workflow Note

The ECS service has this lifecycle setting:

```hcl
ignore_changes = [task_definition]
```

That lets GitHub Actions deploy new image revisions without Terraform trying to roll the service back to the original task definition on the next apply.
