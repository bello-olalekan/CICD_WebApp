# CICD_WebApp

## Deploy to AWS ECS Fargate

This repo includes a GitHub Actions workflow at `.github/workflows/aws.yml` that:

- runs tests
- builds the Docker image
- pushes the image to Amazon ECR
- renders a Fargate task definition
- deploys it to an existing ECS service

Create these GitHub Actions variables:

- `AWS_REGION`, for example `us-east-1`
- `ECR_REPOSITORY`, for example `cicd-webapp`
- `ECS_CLUSTER`
- `ECS_SERVICE`
- `ECS_TASK_EXECUTION_ROLE_ARN`
- optional: `ECS_TASK_FAMILY`, defaults to `cicd-webapp`
- optional: `AWS_LOG_GROUP`, defaults to `/ecs/cicd-webapp`

Create this GitHub Actions secret:

- `AWS_ROLE_TO_ASSUME`: the IAM role GitHub Actions assumes with OIDC

The ECS service should be a Fargate service with networking configured for port `3000`.

## Infrastructure as Code

Terraform files are available in `terraform/` to provision the AWS infrastructure for this app:

- ECR
- CloudWatch Logs
- ECS Fargate
- IAM roles
- GitHub Actions OIDC role
- Application Load Balancer
- Security groups

See `terraform/README.md` before applying, especially if the resources already exist in AWS and need to be imported into Terraform state.
