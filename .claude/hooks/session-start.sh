#!/bin/bash
# Claude Code for Web - SessionStart Hook
# このスクリプトはWebセッション開始時に自動実行されます

set -e

# Web環境でのみ実行（ローカルCLI版では何もしない）
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  echo "Not a web session, skipping web setup"
  exit 0
fi

echo "=== Claude Code Web Session Setup ==="
echo "Setting up development environment..."

# リポジトリのルートに移動（ハードコーディング回避）
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
cd "$REPO_ROOT"

# 環境変数を永続化
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "Configuring environment variables..."
  cat >> "$CLAUDE_ENV_FILE" << 'ENVEOF'
export RAILS_ENV=development
export PATH="/opt/rbenv/versions/3.3.6/bin:$PATH"
ENVEOF
fi

# PATHを即座に設定
export PATH="/opt/rbenv/versions/3.3.6/bin:$PATH"

# システムパッケージのインストール（pg gem用）
echo "Installing system dependencies..."
apt-get update -qq 2>/dev/null || true
apt-get install -y -qq libpq-dev 2>/dev/null || echo "Warning: Could not install libpq-dev"

# bundle install
echo "Installing Ruby gems (this may take a few minutes)..."
if bundle install 2>&1 | tail -20; then
  echo "Bundle install completed successfully"
else
  echo "Some gems failed to install"
  echo "Continuing with available gems..."
fi

# binstubs作成
echo "Creating binstubs..."
bundle binstubs rubocop sorbet tapioca --path=.bundle/bin 2>/dev/null || true

# 開発ツールの確認
echo ""
echo "=== Checking available tools ==="
if [ -x ".bundle/bin/rubocop" ]; then
  echo "✓ RuboCop available (.bundle/bin/rubocop)"
fi
if [ -x ".bundle/bin/srb" ]; then
  echo "✓ Sorbet available (.bundle/bin/srb)"
fi
if [ -x ".bundle/bin/tapioca" ]; then
  echo "✓ Tapioca available (.bundle/bin/tapioca)"
fi

echo ""
echo "=== Web Session Setup Complete ==="
echo ""

exit 0
