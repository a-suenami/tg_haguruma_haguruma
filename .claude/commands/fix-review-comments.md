---
description: GitHub PRのレビューコメントを確認してコードを修正する
argument-hint: "<PR番号 または URL>"
allowed-tools: ["Task", "Bash", "Read", "Edit", "Write"]
---

# レビューコメント対応

対象PR: `$ARGUMENTS`

## 実行方法

### 1. レビューコメントを取得

```bash
# PR情報を取得
gh pr view <PR番号> --json title,body,baseRefName,headRefName

# レビューコメントを取得（行コメント）
gh api repos/{owner}/{repo}/pulls/<PR番号>/comments --jq '.[] | {path: .path, line: .line, body: .body, user: .user.login, created_at: .created_at}'

# PRレビュー（全体コメント）を取得
gh api repos/{owner}/{repo}/pulls/<PR番号>/reviews --jq '.[] | {state: .state, body: .body, user: .user.login}'

# Issue形式のコメントも取得
gh pr view <PR番号> --json comments --jq '.comments[] | {body: .body, author: .author.login}'
```

### 2. コメント一覧を表示

取得したコメントを以下の形式で表示：

```
## レビューコメント一覧

### コメント 1
- ファイル: [path]
- 行: [line]
- 投稿者: [user]
- 内容: [body]
- 対応方針: [提案]

### コメント 2
...
```

### 3. 対応方針を提案

各コメントに対して：
- **対応必要**: コード修正が必要
- **議論必要**: 著者（ユーザー）の判断が必要
- **対応済み**: 既に対応されている
- **対応不要**: 理由を説明

### 4. ユーザーの指示を待つ

**重要**: コード修正を行う前に、必ずユーザーに対応方針を確認してください。

表示例：
```
上記のコメントに対応しますか？
- 全て対応: 「対応して」
- 選択的に対応: 「コメント1と3に対応して」
- 方針確認: 「コメント2についてはどう思いますか？」
```

### 5. コードを修正（ユーザーの指示後）

ユーザーの指示があった場合のみ：

1. 該当ファイルを読み込む
2. レビューコメントに従って修正
3. 修正内容をユーザーに説明
4. RuboCop / Sorbet チェックを実行

### 6. コミット（ユーザーの指示があれば）

```bash
git add <修正ファイル>
git commit -m "fix: address review comments from PR #<番号>

- [修正内容1]
- [修正内容2]
"
```

## 注意事項

- コード修正は必ずユーザーの承認後に実行
- 修正内容はユーザーに明確に説明
- 議論が必要なコメントは修正せず、ユーザーに判断を委ねる
- 修正後は自動的にコミットしない（ユーザーの指示を待つ）
