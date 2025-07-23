local app_environment = import '../../templates/rails_environment.libsonnet';
local app_secrets = import '../../templates/rails_secrets.libsonnet';
local app_image_tag = std.extVar('APP_IMAGE_TAG');

local cpu = 512;
local memory = 3000;
local memory_reservation = 1024;

{
  "containerDefinitions": [
    {
      "cpu": cpu,
      "environment": app_environment + [
        {
          "name": "RAILS_MAX_THREADS",
          "value": "8"
        },
        {
          "name": "RAILS_WORKERS",
          "value": "2"
        }
      ],
      "essential": true,
      "image": "218794653131.dkr.ecr.ap-northeast-1.amazonaws.com/triple-main-app-stg:" + app_image_tag,
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Host": "http-intake.logs.datadoghq.com",
          "Name": "datadog",
          "TLS": "on",
          "dd_service": "triple-app",
          "dd_source": "ruby",
          "dd_tags": "env:qa",
          "provider": "ecs"
        },
        "secretOptions": [
          {
            "name": "apikey",
            "valueFrom": "/triple/qa/ecs/main/datadog_api_key"
          }
        ]
      },
      "memory": memory,
      "memoryReservation": memory_reservation,
      "mountPoints": [],
      "name": "app",
      "portMappings": [],
      "secrets": app_secrets,
      "volumesFrom": []
    },
    {
      "command": [
        "/bin/bash",
        "-c",
        "envsubst '$HEALTH_CHECK_ALLOW_IPS $RULER_ALLOW_IPS' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"
      ],
      "cpu": 256,
      "environment": [
        {
          "name": "RULER_ALLOW_IPS",
          "value": "allow 167.179.95.236/32; allow 219.104.123.178/32; allow 217.178.59.190/32; allow 202.238.212.12/32; allow 202.238.212.13/32; allow 18.180.249.50/32; allow 240d:1b:5c:9600::/56; allow 240d:1b:ad::/56; allow 2409:10:2500:3700::/56;"
        },
        {
          "name": "HEALTH_CHECK_ALLOW_IPS",
          "value": "allow 10.83.0.0/16; allow 52.193.111.118/32; allow 52.196.125.133/32; allow 13.113.213.40/32; allow 52.197.186.229/32; allow 52.198.79.40/32; allow 13.114.12.29/32; allow 13.113.240.89/32; allow 52.68.245.9/32; allow 13.112.142.176/32; allow 52.197.243.193/32;"
        }
      ],
      "essential": true,
      "image": "218794653131.dkr.ecr.ap-northeast-1.amazonaws.com/triple-main-nginx-stg@sha256:e7e1f3320117fc17b483d2f530915e40314f652d0511030f4b667bf3b0cfaaa5",
      "links": [
        "app"
      ],
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Host": "http-intake.logs.datadoghq.com",
          "Name": "datadog",
          "TLS": "on",
          "dd_service": "triple-nginx",
          "dd_source": "nginx",
          "dd_tags": "env:qa",
          "provider": "ecs"
        },
        "secretOptions": [
          {
            "name": "apikey",
            "valueFrom": "/triple/qa/ecs/main/datadog_api_key"
          }
        ]
      },
      "memory": 256,
      "memoryReservation": 128,
      "mountPoints": [],
      "name": "nginx",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 0,
          "protocol": "tcp"
        }
      ],
      "systemControls": [],
      "volumesFrom": []
    },
    {
      "cpu": 64,
      "environment": [],
      "essential": true,
      "firelensConfiguration": {
        "options": {
          "config-file-type": "file",
          "config-file-value": "/fluent-bit/configs/parse-json.conf",
          "enable-ecs-log-metadata": "true"
        },
        "type": "fluentbit"
      },
      "image": "amazon/aws-for-fluent-bit:2.28.4",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/firelens",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "app"
        }
      },
      "memoryReservation": 50,
      "mountPoints": [],
      "name": "log_router",
      "portMappings": [],
      "systemControls": [],
      "user": "0",
      "volumesFrom": []
    }
  ],
  "executionRoleArn": "arn:aws:iam::218794653131:role/triple-main-ecs-task-execution-qa",
  "family": "triple-main-service-app-qa",
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
