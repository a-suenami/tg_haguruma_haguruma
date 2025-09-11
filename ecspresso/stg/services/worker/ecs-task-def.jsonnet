local worker_environment = import '../../templates/rails_environment.libsonnet';
local worker_secrets = import '../../templates/rails_secrets.libsonnet';
local worker_image_tag = std.extVar('APP_IMAGE_TAG');

local cpu = 1024;
local memory = 1024;
local memory_reservation = 512;

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
      "image": "287511440462.dkr.ecr.ap-northeast-1.amazonaws.com/haguruma-main-app-stg:" + worker_image_tag,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/haguruma-main-service-worker/worker",
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
      "volumesFrom": []
    }
  ],
  "executionRoleArn": "arn:aws:iam::287511440462:role/haguruma-main-ecs-task-execution-stg",
  "family": "haguruma-main-service-worker-stg",
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
