local app_environment = import '../../templates/rails_environment.libsonnet';
local app_secrets = import '../../templates/rails_secrets.libsonnet';
local app_image_tag = std.extVar('APP_IMAGE_TAG');

// Fargate
local cpu = 512;
local memory = 1024;


{
  "containerDefinitions": [
    {
      "cpu": 0,
      "environment": app_environment + [
        {
          "name": "RAILS_MAX_THREADS",
          "value": "5"
        },
        {
          "name": "RAILS_WORKERS",
          "value": "1"
        }
      ],
      "essential": true,
      "image": "287511440462.dkr.ecr.ap-northeast-1.amazonaws.com/haguruma-main-app-stg:" + app_image_tag,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/haguruma-main-service-app/app",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "app"
        }
      },
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
      "cpu": 0,
      "environment": [
        {
          "name": "RULER_ALLOW_IPS",
          "value": "allow 219.104.123.178/32; allow 217.178.59.190/32; allow 240d:1b:5c:9600::/56; allow 240d:1b:ad::/56; allow 2409:10:2500:3700::/56; allow 104.30.178.3/32; allow 2a09:bac0:1001:4c8::/64; allow 104.30.166.116/32; allow 2a09:bac0:1000:b44::/64;"
        },
        {
          "name": "HEALTH_CHECK_ALLOW_IPS",
          "value": "allow 10.85.0.0/16; allow 52.193.111.118/32; allow 52.196.125.133/32; allow 13.113.213.40/32; allow 52.197.186.229/32; allow 52.198.79.40/32; allow 13.114.12.29/32; allow 13.113.240.89/32; allow 52.68.245.9/32; allow 13.112.142.176/32; allow 52.197.243.193/32;"
        }
      ],
      "essential": true,
      "image": "287511440462.dkr.ecr.ap-northeast-1.amazonaws.com/haguruma-main-nginx-stg:latest",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/haguruma-main-service-app/nginx",
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "nginx"
        }
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
    }
  ],
  "cpu": std.toString(cpu),
  "executionRoleArn": "arn:aws:iam::287511440462:role/haguruma-main-ecs-task-execution-stg",
  "family": "haguruma-main-service-app-stg",
  "memory": std.toString(memory),
  "networkMode": "awsvpc",
  "requiresCompatibilities": [
    "FARGATE"
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
  "taskRoleArn": "arn:aws:iam::287511440462:role/haguruma-main-ecs-task-stg"
}
