---
description: プルリクエスト全体をレビューする（別コンテキストで実行）
argument-hint: "[base-branch]"
allowed-tools: ["Task", "Bash"]
---

# プルリクエストレビュー

**重要: このレビューはTask toolを使って別コンテキストで実行してください。**

ベースブランチ: `$1` (指定がない場合は main)

## 実行方法

1. 以下のコマンドで情報を取得:
   ```
   git branch --show-current
   git log --oneline main..HEAD
   git diff --name-only main...HEAD
   git diff main...HEAD
   ```

2. Task toolを以下の設定で呼び出す:
   - `subagent_type`: "Explore"
   - `prompt`: 下記のレビュー指示と取得した情報を含める

## Task toolに渡すプロンプト

```
プルリクエストをレビューしてください。

ブランチ情報:
- 現在のブランチ: [ブランチ名]
- ベースブランチ: [main または指定されたブランチ]
- コミット一覧: [git log の結果]
- 変更ファイル: [git diff --name-only の結果]

差分:
[git diff の結果]

## レビュー観点

### 変更の妥当性
- PRの目的に沿った変更か
- 不要な変更が含まれていないか

### コード品質
- Rails ベストプラクティス
- エラーハンドリング

### テスト
- 新機能/変更に対するテスト
- 既存テストへの影響

### パフォーマンス
- N+1 クエリ
- 不要なデータベースアクセス

### セキュリティ
- 認証/認可
- インジェクション脆弱性

### Conventional Commits
- コミットメッセージが規約に従っているか

## 出力フォーマット

# プルリクエストレビュー

## 概要
- ブランチ:
- ベース:
- コミット数:
- 変更ファイル数:

## 変更サマリー

## ファイル別レビュー
[主要な変更ファイルについて]

## 発見事項
### 🔴 CRITICAL（マージ前に必須修正）
### 🟠 IMPORTANT（強く推奨）
### 🟡 SUGGESTION（あれば望ましい）
### 🔵 QUESTION（確認事項）
### ✅ 良い点

## 総合評価
- コード品質: OK / 要改善
- テスト: OK / 要追加
- セキュリティ: OK / 要確認

## 結論
**[APPROVE / REQUEST CHANGES / COMMENT]**
```

## 結果の報告

Task toolからの結果をユーザーにそのまま表示してください。
