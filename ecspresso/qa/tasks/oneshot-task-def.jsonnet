local app_environment = import '../templates/rails_environment.libsonnet';
local app_secrets = import '../templates/rails_secrets.libsonnet';
local app_image_tag = std.extVar('APP_IMAGE_TAG');

local cpu = 10;
local memory = 512;
local memory_reservation = 256;

{
  "containerDefinitions": [
    {
      "command": [],
      "cpu": cpu,
      "entryPoint": [],
      "environment": app_environment,
      "essential": true,
      "image": "218794653131.dkr.ecr.ap-northeast-1.amazonaws.com/triple-main-app-stg:" + app_image_tag,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/triple-main-oneshot-qa/app",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "app"
        }
      },
      "memory": memory,
      "memoryReservation": memory_reservation,
      "mountPoints": [],
      "name": "app",
      "portMappings": [],
      "secrets": app_secrets,
      "volumesFrom": []
    }
  ],
  "executionRoleArn": "arn:aws:iam::218794653131:role/triple-main-ecs-task-execution-qa",
  "family": "triple-main-oneshot-qa",
  "placementConstraints": [],
  "requiresCompatibilities": [
    "EC2"
  ],
  "tags": [
    {
      "key": "env",
      "value": "qa"
    },
    {
      "key": "project",
      "value": "triple"
    }
  ],
  "taskRoleArn": "arn:aws:iam::218794653131:role/triple-main-ecs-task-qa",
  "volumes": []
}

