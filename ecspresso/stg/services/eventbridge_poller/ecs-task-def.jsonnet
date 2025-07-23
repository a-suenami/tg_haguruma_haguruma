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
      "image": "218794653131.dkr.ecr.ap-northeast-1.amazonaws.com/triple-main-app-stg:" + poller_image_tag,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/triple-main-service-eventbridge-poller/poller",
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
  "executionRoleArn": "arn:aws:iam::218794653131:role/triple-main-ecs-task-execution-stg",
  "family": "triple-main-service-eventbridge-poller-stg",
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
      "value": "triple"
    }
  ],
  "taskRoleArn": "arn:aws:iam::218794653131:role/triple-main-ecs-task-stg",
  "volumes": []
}
