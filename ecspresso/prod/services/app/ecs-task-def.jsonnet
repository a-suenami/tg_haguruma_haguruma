local app_environment = import '../../templates/rails_environment.libsonnet';
local app_secrets = import '../../templates/rails_secrets.libsonnet';
local app_image_tag = std.extVar('APP_IMAGE_TAG');

// Fargate
local cpu = 4096;
local memory = 8192;

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
          "value": "4"
        }
      ],
      "essential": true,
      "image": "430013787765.dkr.ecr.ap-northeast-1.amazonaws.com/triple-main-app-prod:" + app_image_tag,
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Name": "datadog",
          "Host": "http-intake.logs.datadoghq.com",
          "dd_service": "triple-app",
          "dd_source": "ruby",
          "dd_tags": "env:production",
          "TLS": "on",
          "provider": "ecs"
        },
        "secretOptions": [
          {
            "name": "apikey",
            "valueFrom": "/triple/prod/ecs/main/datadog_api_key"
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
          "value": "allow 167.179.95.236/32; allow 219.104.123.178/32; allow 217.178.59.190/32; allow 202.238.212.12/32; allow 202.238.212.13/32; allow 18.180.249.50/32; allow 240d:1b:5c:9600::/56; allow 240d:1b:ad::/56; allow 2409:10:2500:3700::/56; allow 104.30.178.3/32; allow 2a09:bac0:1001:4c8::/64; allow 104.30.166.116/32; allow 2a09:bac0:1000:b44::/64;"
        },
        {
          "name": "HEALTH_CHECK_ALLOW_IPS",
          "value": "allow 10.82.0.0/16; allow 52.193.111.118/32; allow 52.196.125.133/32; allow 13.113.213.40/32; allow 52.197.186.229/32; allow 52.198.79.40/32; allow 13.114.12.29/32; allow 13.113.240.89/32; allow 52.68.245.9/32; allow 13.112.142.176/32; allow 52.197.243.193/32;"
        }
      ],
      "essential": true,
      "image": "430013787765.dkr.ecr.ap-northeast-1.amazonaws.com/triple-main-nginx-prod:latest",
      "logConfiguration": {
        "logDriver": "awsfirelens",
        "options": {
          "Name": "datadog",
          "Host": "http-intake.logs.datadoghq.com",
          "dd_service": "triple-nginx",
          "dd_source": "nginx",
          "dd_tags": "env:production",
          "TLS": "on",
          "provider": "ecs"
        },
        "secretOptions": [
          {
            "name": "apikey",
            "valueFrom": "/triple/prod/ecs/main/datadog_api_key"
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
          "value": "env:prod role:app project:triple"
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
          "valueFrom": "/triple/prod/ecs/main/datadog_api_key"
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
  "executionRoleArn": "arn:aws:iam::430013787765:role/triple-main-ecs-task-execution-prod",
  "family": "triple-main-service-app-prod",
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
      "value": "prod"
    },
    {
      "key": "project",
      "value": "triple"
    }
  ],
  "taskRoleArn": "arn:aws:iam::430013787765:role/triple-main-ecs-task-prod",
  "volumes": []
}
