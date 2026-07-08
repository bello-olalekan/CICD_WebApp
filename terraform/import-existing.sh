#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

AWS_REGION="${AWS_REGION:-us-east-1}"
ECR_REPOSITORY_NAME="${ECR_REPOSITORY_NAME:-cicd-webapp}"
LOG_GROUP_NAME="${LOG_GROUP_NAME:-/ecs/cicd-webapp}"
ECS_CLUSTER_NAME="${ECS_CLUSTER_NAME:-sunny-eagle-8hn96b}"
ECS_SERVICE_NAME="${ECS_SERVICE_NAME:-cicd-webapp-service}"
ECS_TASK_EXECUTION_ROLE_NAME="${ECS_TASK_EXECUTION_ROLE_NAME:-ecsTaskExecutionRole}"
GITHUB_ACTIONS_ROLE_NAME="${GITHUB_ACTIONS_ROLE_NAME:-github-actions-cicd-webapp-role}"
ECS_TASK_SECURITY_GROUP_NAME="${ECS_TASK_SECURITY_GROUP_NAME:-cicd-webapp-task-sg}"
ALB_SECURITY_GROUP_NAME="${ALB_SECURITY_GROUP_NAME:-cicd-webapp-alb-sg}"
ALB_NAME="${ALB_NAME:-cicd-webapp-alb}"
TARGET_GROUP_NAME="${TARGET_GROUP_NAME:-cicd-webapp-tg}"

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

query() {
  aws "$@" --region "$AWS_REGION" --output text 2>/dev/null || true
}

import_resource() {
  local address="$1"
  local id="$2"

  if [[ -z "$id" || "$id" == "None" || "$id" == "null" ]]; then
    echo "skip: $address - no existing AWS resource found"
    return
  fi

  if terraform state show "$address" >/dev/null 2>&1; then
    echo "skip: $address - already imported"
    return
  fi

  echo "import: $address <- $id"
  terraform import "$address" "$id"
}

echo "Initializing Terraform..."
terraform init

echo "Discovering existing AWS resources in $AWS_REGION..."

VPC_ID="$(query ec2 describe-vpcs \
  --filters Name=is-default,Values=true \
  --query 'Vpcs[0].VpcId')"

ECS_TASK_SECURITY_GROUP_ID="$(query ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=$ECS_TASK_SECURITY_GROUP_NAME" \
  --query 'SecurityGroups[0].GroupId')"

ALB_SECURITY_GROUP_ID="$(query ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=$ALB_SECURITY_GROUP_NAME" \
  --query 'SecurityGroups[0].GroupId')"

ALB_ARN="$(query elbv2 describe-load-balancers \
  --names "$ALB_NAME" \
  --query 'LoadBalancers[0].LoadBalancerArn')"

TARGET_GROUP_ARN="$(query elbv2 describe-target-groups \
  --names "$TARGET_GROUP_NAME" \
  --query 'TargetGroups[0].TargetGroupArn')"

LISTENER_ARN=""
if [[ -n "$ALB_ARN" && "$ALB_ARN" != "None" ]]; then
  LISTENER_ARN="$(query elbv2 describe-listeners \
    --load-balancer-arn "$ALB_ARN" \
    --query 'Listeners[?Port==`80`].ListenerArn | [0]')"
fi

echo "Importing resources..."

import_resource "aws_ecr_repository.app" "$ECR_REPOSITORY_NAME"
import_resource "aws_cloudwatch_log_group.app" "$LOG_GROUP_NAME"
import_resource "aws_ecs_cluster.app" "$ECS_CLUSTER_NAME"
import_resource "aws_iam_role.ecs_task_execution" "$ECS_TASK_EXECUTION_ROLE_NAME"
import_resource "aws_iam_role.github_actions" "$GITHUB_ACTIONS_ROLE_NAME"
import_resource "aws_security_group.ecs_tasks" "$ECS_TASK_SECURITY_GROUP_ID"
import_resource "aws_security_group.alb" "$ALB_SECURITY_GROUP_ID"
import_resource "aws_lb.app" "$ALB_ARN"
import_resource "aws_lb_target_group.app" "$TARGET_GROUP_ARN"
import_resource "aws_lb_listener.http" "$LISTENER_ARN"
import_resource "aws_ecs_service.app" "$ECS_CLUSTER_NAME/$ECS_SERVICE_NAME"

import_resource \
  "aws_iam_role_policy_attachment.ecs_task_execution" \
  "$ECS_TASK_EXECUTION_ROLE_NAME/arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

import_resource \
  "aws_iam_role_policy_attachment.github_actions_ecr" \
  "$GITHUB_ACTIONS_ROLE_NAME/arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"

import_resource \
  "aws_iam_role_policy_attachment.github_actions_ecs" \
  "$GITHUB_ACTIONS_ROLE_NAME/arn:aws:iam::aws:policy/AmazonECS_FullAccess"

import_resource \
  "aws_iam_role_policy_attachment.github_actions_logs" \
  "$GITHUB_ACTIONS_ROLE_NAME/arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"

import_resource \
  "aws_iam_role_policy.github_actions_pass_role" \
  "$GITHUB_ACTIONS_ROLE_NAME:AllowPassEcsTaskExecutionRole"

echo
echo "Import pass complete."
echo "Next command:"
echo "  terraform plan"
