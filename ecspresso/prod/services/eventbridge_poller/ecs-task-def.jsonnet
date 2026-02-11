local poller_environment = import '../../templates/rails_environment.libsonnet';
local poller_secrets = import '../../templates/rails_secrets.libsonnet';
local poller_image_tag = std.extVar('APP_IMAGE_TAG');

local cpu = 256;
local memory = 512;
local memory_reservation = 256;

{
  "containerDefinitions": [
    {
      "command": [
        "bash",
        "bin/eventbridge_poller"
      ],
      "cpu": cpu,
      "entryPoint": [],
      "environment": poller_environment + [
        {
          "name": "RAILS_MAX_THREADS",
          "value": "1"
        },
        {
          "name": "RAILS_WORKERS",
          "value": "1"
        }
      ],
      "essential": true,
      "image": "843188904699.dkr.ecr.ap-northeast-1.amazonaws.com/haguruma-main-app-prod:" + poller_image_tag,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/haguruma-main-service-eventbridge-poller/poller",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "poller"
        }
      },
      "memory": memory,
      "memoryReservation": memory_reservation,
      "mountPoints": [],
      "name": "poller",
      "portMappings": [],
      "secrets": poller_secrets,
      "stopTimeout": 120,
      "volumesFrom": []
    }
  ],
  "executionRoleArn": "arn:aws:iam::843188904699:role/haguruma-main-ecs-task-execution-prod",
  "family": "haguruma-main-service-eventbridge-poller-prod",
  "placementConstraints": [],
  "requiresCompatibilities": [
    "EC2"
  ],
  "tags": [
    {
      "key": "env",
      "value": "prod"
    },
    {
      "key": "project",
      "value": "haguruma"
    }
  ],
  "taskRoleArn": "arn:aws:iam::843188904699:role/haguruma-main-ecs-task-prod",
  "volumes": []
}
