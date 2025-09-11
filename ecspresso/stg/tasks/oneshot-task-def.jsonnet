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
      "image": "287511440462.dkr.ecr.ap-northeast-1.amazonaws.com/haguruma-main-app-stg:" + app_image_tag,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/haguruma-main-oneshot/app",
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
  "executionRoleArn": "arn:aws:iam::287511440462:role/haguruma-main-ecs-task-execution-stg",
  "family": "haguruma-main-oneshot-stg",
  "placementConstraints": [],
  "requiresCompatibilities": [
    "EC2"
  ],
  "tags": [
    {
      "key": "env",
      "value": "stg"
    },
    {
      "key": "project",
      "value": "haguruma"
    }
  ],
  "taskRoleArn": "arn:aws:iam::287511440462:role/haguruma-main-ecs-task-stg",
  "volumes": []
}

