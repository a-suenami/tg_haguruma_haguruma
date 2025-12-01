#!/bin/bash
# Claude Code for Web - SessionStart Hook
# このスクリプトはWebセッション開始時に自動実行されます

set -e

# Web環境でのみ実行
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
  echo "Not a web session, skipping web setup"
  exit 0
fi

echo "=== Claude Code Web Session Setup ==="
echo "Setting up development environment..."

cd /home/user/tg_haguruma_haguruma

# 環境変数を永続化
if [ -n "$CLAUDE_ENV_FILE" ]; then
  echo "Configuring environment variables..."
  cat >> "$CLAUDE_ENV_FILE" << 'ENVEOF'
export RAILS_ENV=development
export BUNDLE_WITHOUT=production
export PATH="/opt/rbenv/versions/3.3.6/bin:$PATH"
ENVEOF
fi

# PATHを即座に設定
export PATH="/opt/rbenv/versions/3.3.6/bin:$PATH"

# bundle install（pg gemなどネイティブ拡張が失敗しても続行）
echo "Installing Ruby gems (this may take a few minutes)..."
if bundle install --without production 2>&1 | tail -20; then
  echo "Bundle install completed successfully"
else
  echo "Some gems failed to install (likely native extensions like pg)"
  echo "Continuing with available gems..."
fi

# RuboCop, Sorbet などの開発ツールが使えるか確認
echo ""
echo "=== Checking available tools ==="
if command -v /opt/rbenv/versions/3.3.6/bin/rubocop &> /dev/null; then
  echo "✓ RuboCop available"
fi
if command -v /opt/rbenv/versions/3.3.6/bin/srb &> /dev/null; then
  echo "✓ Sorbet available"
fi

echo ""
echo "=== Web Session Setup Complete ==="
echo "Note: Some features requiring database connection may not work"
echo ""

exit 0
