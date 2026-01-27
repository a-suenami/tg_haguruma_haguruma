local app_environment = import '../../templates/rails_environment.libsonnet';
local app_secrets = import '../../templates/rails_secrets.libsonnet';
local app_image_tag = std.extVar('APP_IMAGE_TAG');

// Fargate
local cpu = 2048;
local memory = 4096;

// Container
local nginx_cpu = 256;
local nginx_memory = 256;
local fluentbit_cpu = 128;
local fluentbit_memory = 128;
local datadog_cpu = 128;
local datadog_memory = 128;
local rails_cpu = cpu - nginx_cpu - fluentbit_cpu - datadog_cpu;
local rails_memory = memory - nginx_memory - fluentbit_memory - datadog_memory;


{
  "containerDefinitions": [
    {
      "cpu": rails_cpu,
      "environment": app_environment + [
        {
          "name": "RAILS_MAX_THREADS",
          "value": "5"
        },
        {
          "name": "RAILS_WORKERS",
          "value": "2"
        }
      ],
      "essential": true,
      "image": "843188904699.dkr.ecr.ap-northeast-1.amazonaws.com/haguruma-main-app-prod:" + app_image_tag,
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Name": "datadog",
          "Host": "http-intake.logs.datadoghq.com",
          "dd_service": "haguruma-app",
          "dd_source": "app",
          "dd_tags": "env:production",
          "TLS": "on",
          "provider": "ecs"
        },
        "secretOptions": [
          {
            "name": "apikey",
            "valueFrom": "/haguruma/prod/ecs/main/datadog_api_key"
          }
        ]
      },
      "memoryReservation": rails_memory,
      "name": "app",
      "secrets": app_secrets,
      "versionConsistency": ""
    },
    {
      "command": [
        "/bin/bash",
        "-c",
        "envsubst '$HEALTH_CHECK_ALLOW_IPS $RULER_ALLOW_IPS' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'"
      ],
      "cpu": nginx_cpu,
      "environment": [
        {
          "name": "RULER_ALLOW_IPS",
          "value": "allow 219.104.123.178/32; allow 217.178.59.190/32; allow 240d:1b:5c:9600::/56; allow 240d:1b:ad::/56; allow 2409:10:2500:3700::/56; allow 104.30.178.3/32; allow 2a09:bac0:1001:4c8::/64; allow 104.30.166.116/32; allow 2a09:bac0:1000:b44::/64;"
        },
        {
          "name": "HEALTH_CHECK_ALLOW_IPS",
          "value": "allow 10.84.0.0/16; allow 52.193.111.118/32; allow 52.196.125.133/32; allow 13.113.213.40/32; allow 52.197.186.229/32; allow 52.198.79.40/32; allow 13.114.12.29/32; allow 13.113.240.89/32; allow 52.68.245.9/32; allow 13.112.142.176/32; allow 52.197.243.193/32;"
        }
      ],
      "memoryReservation": nginx_memory,
      "essential": true,
      "image": "843188904699.dkr.ecr.ap-northeast-1.amazonaws.com/haguruma-main-nginx-prod:latest",
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Name": "datadog",
          "Host": "http-intake.logs.datadoghq.com",
          "dd_service": "haguruma-nginx",
          "dd_source": "nginx",
          "dd_tags": "env:production",
          "TLS": "on",
          "provider": "ecs"
        },
        "secretOptions": [
          {
            "name": "apikey",
            "valueFrom": "/haguruma/prod/ecs/main/datadog_api_key"
          }
        ]
      },
      "name": "nginx",
      "portMappings": [
        {
          "appProtocol": "",
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "versionConsistency": ""
    },
        {
      "essential": true,
      "image": "public.ecr.aws/aws-observability/aws-for-fluent-bit:2.28.4",
      "name": "log_router",
      "firelensConfiguration": {
          "type": "fluentbit",
          "options": {
              "enable-ecs-log-metadata": "true",
              "config-file-type": "file",
              "config-file-value": "/fluent-bit/configs/parse-json.conf"
          }
      },
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "/ecs/firelens",
              "awslogs-region": "ap-northeast-1",
              "awslogs-stream-prefix": "app"
          }
      },
      "environment": null,
      "secrets": null,
      "memoryReservation": fluentbit_memory,
      "cpu": fluentbit_cpu,
    },
    // datadog
    {
      "name": "datadog",
      "image": "gcr.io/datadoghq/agent:latest",
      "cpu": datadog_cpu,
      "memoryReservation": datadog_memory,
      "portMappings": [],
      "essential": true,
      "environment": [
        {
          "name": "ECS_FARGATE",
          "value": "true"
        },
        {
          "name": "DD_APM_ENABLED",
          "value": "true"
        },
        {
          "name": "DD_APM_IGNORE_RESOURCES",
          "value": "Rails::HealthController#show"
        },
        {
          "name": "DD_TAGS",
          "value": "env:prod role:app project:haguruma"
        },
        {
          "name": "DD_SITE",
          "value": "datadoghq.com"
        }
      ],
      "environmentFiles": [],
      "mountPoints": [],
      "volumesFrom": [],
      "secrets": [
        {
          "name": "DD_API_KEY",
          "valueFrom": "/haguruma/prod/ecs/main/datadog_api_key"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/haguruma-main-service-app/datadog",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "ecs"
        },
        "secretOptions": []
      },
      "systemControls": []
    }
  ],
  "cpu": std.toString(cpu),
  "executionRoleArn": "arn:aws:iam::843188904699:role/haguruma-main-ecs-task-execution-prod",
  "family": "haguruma-main-service-app-prod",
  "memory": std.toString(memory),
  "networkMode": "awsvpc",
  "requiresCompatibilities": [
    "FARGATE"
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
  "taskRoleArn": "arn:aws:iam::843188904699:role/haguruma-main-ecs-task-prod"
}
