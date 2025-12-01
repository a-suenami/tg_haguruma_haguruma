---
description: GitHub PRをレビューする（PR番号またはURLを指定）
argument-hint: "<PR番号 または URL>"
allowed-tools: ["Task", "Bash"]
---

# GitHub PR レビュー

**重要: このレビューはTask toolを使って別コンテキストで実行してください。**

対象PR: `$ARGUMENTS`

## 実行方法

### 1. PR情報を取得

```bash
# PR番号を抽出（URLの場合は末尾の数字）
gh pr view <PR番号> --json title,body,author,baseRefName,headRefName,additions,deletions,changedFiles,comments,reviews

# 差分を取得
gh pr diff <PR番号>

# 既存のレビューコメントを取得
gh api repos/{owner}/{repo}/pulls/<PR番号>/comments
```

### 2. Task toolでレビュー実行

以下の設定で呼び出す:
- `subagent_type`: "Explore"
- `prompt`: 下記のレビュー指示とPR情報・差分を含める

## Task toolに渡すプロンプト

```
GitHub Pull Requestをレビューしてください。

## PR情報
- タイトル: [title]
- 作成者: [author]
- ベースブランチ: [baseRefName]
- ヘッドブランチ: [headRefName]
- 変更ファイル数: [changedFiles]
- 追加行: [additions] / 削除行: [deletions]

## PR説明
[body]

## 差分
[gh pr diff の結果]

## 既存のコメント/レビュー
[既にあれば記載]

## レビュー観点

### 変更の妥当性
- PRの目的に沿った変更か
- 不要な変更が含まれていないか

### コード品質
- Rails ベストプラクティス
- 可読性、保守性

### テスト
- テストカバレッジ
- エッジケース

### パフォーマンス
- N+1 クエリ
- 不要なDB/APIアクセス

### セキュリティ
- 認証/認可
- インジェクション脆弱性

## 出力フォーマット

# PR レビュー結果

## 概要
- PR: #[番号] [タイトル]
- 変更規模: [小/中/大]

## 発見事項

### 🔴 CRITICAL（マージブロック）
[ファイル名:行番号] 問題の説明

### 🟠 IMPORTANT（強く推奨）
[ファイル名:行番号] 問題の説明

### 🟡 SUGGESTION（あれば望ましい）
[ファイル名:行番号] 提案内容

### 🔵 QUESTION（確認事項）
質問内容

### ✅ 良い点
良い実装のポイント

## 総合評価
**[APPROVE / REQUEST CHANGES / COMMENT]**

理由: [簡潔に]
```

## 3. 結果をユーザーに表示

Task toolの結果をそのまま表示してください。

## 4. コメント投稿（ユーザーの指示があれば）

ユーザーが「このコメントを投稿して」と指示した場合のみ：

```bash
# PR全体へのコメント
gh pr comment <PR番号> --body "コメント内容"

# 特定行へのレビューコメント（ユーザーが明示的に指示した場合）
gh api repos/{owner}/{repo}/pulls/<PR番号>/comments \
  -f body="コメント内容" \
  -f path="ファイルパス" \
  -f line=行番号 \
  -f side="RIGHT"
```

**注意**: コメント投稿は必ずユーザーの承認を得てから行うこと。
