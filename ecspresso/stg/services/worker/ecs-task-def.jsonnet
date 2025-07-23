local worker_environment = import '../../templates/rails_environment.libsonnet';
local worker_secrets = import '../../templates/rails_secrets.libsonnet';
local worker_image_tag = std.extVar('APP_IMAGE_TAG');

local cpu = 512;
local memory = 15000;
local memory_reservation = 3000;

{
  "containerDefinitions": [
    {
      "command": [
        "bash",
        "bin/sidekiq-entrypoint.sh",
        "bundle",
        "exec",
        "sidekiq",
        "-C",
        "config/sidekiq.yml"
      ],
      "cpu": cpu,
      "entryPoint": [],
      "environment": worker_environment + [
        {
          "name": "RAILS_MAX_THREADS",
          "value": "20"
        },
        {
          "name": "RAILS_WORKERS",
          "value": "1"
        }
      ],
      "essential": true,
      "image": "218794653131.dkr.ecr.ap-northeast-1.amazonaws.com/triple-main-app-stg:" + worker_image_tag,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/triple-main-service-worker/worker",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "worker"
        }
      },
      "memory": memory,
      "memoryReservation": memory_reservation,
      "mountPoints": [],
      "name": "worker",
      "portMappings": [],
      "secrets": worker_secrets,
      "stopTimeout": 120,
      "dnsServers": [
        "172.17.0.1"
      ],
      "volumesFrom": []
    }
  ],
  "executionRoleArn": "arn:aws:iam::218794653131:role/triple-main-ecs-task-execution-stg",
  "family": "triple-main-service-worker-stg",
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
