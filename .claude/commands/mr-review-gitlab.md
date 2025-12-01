---
description: GitLab MRをレビューする（MR番号またはURLを指定）
argument-hint: "<MR番号 または URL>"
allowed-tools: ["Task", "Bash"]
---

# GitLab MR レビュー

**重要: このレビューはTask toolを使って別コンテキストで実行してください。**

対象MR: `$ARGUMENTS`

## 実行方法

### 1. MR情報を取得

```bash
# MR情報を取得
glab mr view <MR番号> --output json

# 差分を取得
glab mr diff <MR番号>

# ディスカッション（コメント）を取得
glab api projects/:id/merge_requests/<MR番号>/discussions
```

### 2. Task toolでレビュー実行

以下の設定で呼び出す:
- `subagent_type`: "Explore"
- `prompt`: 下記のレビュー指示とMR情報・差分を含める

## Task toolに渡すプロンプト

```
GitLab Merge Requestをレビューしてください。

## MR情報
- タイトル: [title]
- 作成者: [author]
- ソースブランチ: [source_branch]
- ターゲットブランチ: [target_branch]
- 変更ファイル数: [changes_count]

## MR説明
[description]

## 差分
[glab mr diff の結果]

## 既存のディスカッション
[既にあれば記載]

## レビュー観点

### 変更の妥当性
- MRの目的に沿った変更か
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

# MR レビュー結果

## 概要
- MR: ![番号] [タイトル]
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
# MR全体へのコメント（ノート）
glab mr note <MR番号> --message "コメント内容"

# 特定行へのコメント（ディスカッション）
glab api projects/:id/merge_requests/<MR番号>/discussions \
  -X POST \
  -f "body=コメント内容" \
  -f "position[base_sha]=<base_sha>" \
  -f "position[start_sha]=<start_sha>" \
  -f "position[head_sha]=<head_sha>" \
  -f "position[position_type]=text" \
  -f "position[new_path]=ファイルパス" \
  -f "position[new_line]=行番号"
```

**注意**: コメント投稿は必ずユーザーの承認を得てから行うこと。
