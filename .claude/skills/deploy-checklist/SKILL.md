---
name: deploy-checklist
description: Generate a deployment verification checklist by analyzing the diff between current branch and deploy-production.
user-invocable: true
---

# Deploy Checklist Generator

Generate a deployment verification checklist from the diff between the current branch and `deploy-production`.

## Steps

1. Run `git diff --stat deploy-production..HEAD` and `git log --oneline deploy-production..HEAD` to understand the scope of changes.
2. Run `git diff deploy-production..HEAD` to read the full diff.
3. Analyze all changes and categorize them into logical groups.
4. Assess risk level for each group based on **user impact after deployment** (not whether deployment itself fails).
5. Output the checklist in the format below.

## Risk Level Criteria

- **High**: Changes that directly affect end-user-visible content or functionality. If broken, users see missing images, broken pages, or can't use core features.
- **Medium**: Changes that affect specific screens or flows. If broken, a particular feature degrades but the app mostly works.
- **Low**: Admin-only changes, pure refactors with identical behavior, or changes that only block deployment without affecting users.

Important: If a failure only prevents deployment from completing (e.g., DB constraint violation that aborts migration), it is NOT High risk.

## Output Format

Output as GitLab Markdown with checkboxes. Start with a summary assessment block, then list items in descending risk order.

```
## 総合リスク評価: {低/中/中〜高/高}（{一言サマリー}）

{2〜3文で、このデプロイの全体的なリスク感と特に注意すべきポイントを説明}

---

### High（ユーザーに直接見える壊れ方をする）

#### {変更グループ名}
{影響の説明}

- [ ] {検証項目}（{確認画面パス}）
  - [ ] {子項目がある場合はネスト}

### Medium（特定画面・特定フローに影響）

#### {変更グループ名}
...

### Low（スキップ可）

- [ ] {項目名のみ簡潔に}
```

## Rules

- Every verification item must start with `- [ ]`
- Include the screen path (e.g., `/blog/:id`, `/admin/media`) for each item
- Use nested `- [ ]` for sub-items when a group of screens needs the same check
- Low risk items: one line each, no sub-items
- Keep the summary assessment honest and actionable — if it's safe, say so clearly

## Project Screen Paths Reference

- User pages: `/`, `/blog`, `/blog/:id`, `/news/:id`, `/schedules`, `/schedules/:id`, `/tickets`, `/tickets/:id`, `/biographies/:id`, `/privileges/:id`, `/login`
- Admin pages: `/admin/media`, `/admin/content`
- API: Content Delivery API
