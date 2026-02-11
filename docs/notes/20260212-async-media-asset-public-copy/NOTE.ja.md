# MediaAsset 公開コピーの非同期化

## 背景

コンテンツ公開時に `VisibilitySyncService` が private フォルダから public フォルダへ S3 オブジェクトをコピーするが、この処理は同期的に実行されている。

```
PublishEntryService#publish
  └─ sync_media_asset_visibility (同期)
       └─ VisibilitySyncService#call
            └─ CopyService#copy_to_public (S3コピー)
```

コンテンツに含まれる MediaAsset の数が多い場合、公開操作のレスポンスタイムに影響する。

## 現状の安全性

`MediaAsset#resolved_url` により、public コピーが存在しない場合でも署名付き URL にフォールバックするため、コピーが遅延しても画像は表示される。

```ruby
def resolved_url
  if public?
    public_url        # 署名なし URL
  else
    url               # 署名付き URL（10分/30分）
  end
end
```

この設計により、S3 コピーを非同期化しても表示上の問題は発生しない。

## 提案

`sync_media_asset_visibility` を Active Job 経由で非同期実行に変更する。

### 対象ファイル

- `app/services/admin_area/contents/publish_entry_service.rb`（呼び出し元）
- `app/services/media_assets/visibility_sync_service.rb`（実処理）

## 関連

- MR: https://git.l.twogate.net/haguruma/haguruma/-/merge_requests/232
