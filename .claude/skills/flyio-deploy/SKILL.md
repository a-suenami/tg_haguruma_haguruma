---
name: Haguruma fly.io Deploy
description: Deploy haguruma Rails app to personal fly.io environment for development
trigger: When user mentions deploying to fly.io, personal staging, or demo environment
---

# Haguruma fly.io Personal Deployment

個人の開発効率化のためのfly.ioデプロイ手順。チームのステージング環境（AWS）とは別。

## Prerequisites

- fly.io CLIがインストール済み: `curl -L https://fly.io/install.sh | sh`
- fly.ioにログイン済み: `fly auth login`

## Initial Setup (初回のみ)

### 1. アプリ作成

```bash
fly apps create haguruma-<your-name>
```

### 2. fly.tomlを作成

プロジェクトルートに `fly.toml` を作成（gitignoreされている前提）:

```toml
app = 'haguruma-<your-name>'
primary_region = 'nrt'

[build]

[http_service]
  internal_port = 80
  force_https = true
  auto_stop_machines = 'stop'
  auto_start_machines = true
  min_machines_running = 0
  processes = ['app']

[[vm]]
  memory = '512mb'
  cpu_kind = 'shared'
  cpus = 1
```

### 3. PostgreSQL作成

```bash
fly postgres create --name haguruma-<your-name>-db --region nrt --vm-size shared-cpu-1x --volume-size 1
fly postgres attach haguruma-<your-name>-db --app haguruma-<your-name>
```

### 4. Secrets設定

```bash
fly secrets set RAILS_MASTER_KEY=$(cat config/master.key) --app haguruma-<your-name>
fly secrets set RAILS_ENV=production --app haguruma-<your-name>
```

## Deploy

```bash
fly deploy --app haguruma-<your-name>
```

## Useful Commands

```bash
# ログ確認
fly logs --app haguruma-<your-name>

# Railsコンソール
fly ssh console --app haguruma-<your-name> -C "/rails/bin/rails console"

# DBマイグレーション
fly ssh console --app haguruma-<your-name> -C "/rails/bin/rails db:migrate"

# アプリ状態確認
fly status --app haguruma-<your-name>

# マシン停止（コスト節約）
fly machine stop --app haguruma-<your-name>

# マシン起動
fly machine start --app haguruma-<your-name>
```

## Notes

- `fly.toml` はリポジトリにコミットしない（個人環境のため）
- `.gitignore` に `fly.toml` を追加しておくこと
- auto_stop_machines=true でアクセスがないときは自動停止（コスト節約）
- 本番デプロイはAWSのステージング環境を使用すること
