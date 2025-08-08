local app_environment = import '../../templates/rails_environment.libsonnet';
local app_secrets = import '../../templates/rails_secrets.libsonnet';
local app_image_tag = std.extVar('APP_IMAGE_TAG');

// Fargate
local cpu = 1024;
local memory = 2048;

// Container
local nginx_cpu = 128;
local nginx_memory = 256;
local fluentbit_cpu = 64;
local fluentbit_memory = 128;
local datadog_cpu = 64;
local datadog_memory = 128;
local rails_cpu = cpu - nginx_cpu - fluentbit_cpu - datadog_cpu;
local rails_memory = memory - nginx_memory - fluentbit_memory - datadog_memory;

{
  "containerDefinitions": [
    {
      "command": [],
      "cpu": rails_cpu,
      "entryPoint": [],
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
          "Name": "datadog",
          "Host": "http-intake.logs.datadoghq.com",
          "dd_service": "triple-app",
          "dd_source": "ruby",
          "dd_tags": "env:staging",
          "TLS": "on",
          "provider": "ecs"
        },
        "secretOptions": [
          {
            "name": "apikey",
            "valueFrom": "/triple/stg/ecs/main/datadog_api_key"
          }
        ]
      },
      "memoryReservation": rails_memory,
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
      "cpu": nginx_cpu,
      "entryPoint": [],
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
      "image": "218794653131.dkr.ecr.ap-northeast-1.amazonaws.com/triple-main-nginx-stg:latest",
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Name": "datadog",
          "Host": "http-intake.logs.datadoghq.com",
          "dd_service": "triple-nginx",
          "dd_source": "nginx",
          "dd_tags": "env:staging",
          "TLS": "on",
          "provider": "ecs"
        },
        "secretOptions": [
          {
            "name": "apikey",
            "valueFrom": "/triple/stg/ecs/main/datadog_api_key"
          }
        ]
      },
      "memoryReservation": nginx_memory,
      "mountPoints": [],
      "name": "nginx",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "volumesFrom": []
    },
    // fluent bit
    {
      "essential": true,
      "image": "amazon/aws-for-fluent-bit:2.28.4",
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
          "value": "env:stg role:app project:triple"
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
          "valueFrom": "/triple/stg/ecs/main/datadog_api_key"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/triple-main-service-app/datadog",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "ecs"
        },
        "secretOptions": []
      },
      "systemControls": []
    }
  ],
  "cpu": std.toString(cpu),
  "executionRoleArn": "arn:aws:iam::218794653131:role/triple-main-ecs-task-execution-stg",
  "family": "triple-main-service-app-stg",
  "memory": std.toString(memory),
  "placementConstraints": [],
  "networkMode": "awsvpc",
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "runtimePlatform": {
    "cpuArchitecture": "X86_64",
    "operatingSystemFamily": "LINUX"
  },
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
