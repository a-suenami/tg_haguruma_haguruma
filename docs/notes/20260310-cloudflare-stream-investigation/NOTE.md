# Cloudflare Stream Video Delivery Investigation Report

## Overview

We investigated the technical feasibility of delivering video content from the media_assets table via Cloudflare Stream instead of CloudFront.

## Summary of Findings

**Conclusion: Technically feasible, with per-tenant billing tracking possible**

### Cloudflare Stream Features

| Item | Details |
|------|---------|
| Storage cost | $5/1,000 minutes (based on video duration, independent of file size) |
| Delivery cost | $1/1,000 minutes (based on delivered minutes) |
| Encoding | Automatic (uploaded videos are automatically converted to HLS/DASH) |
| CDN | Automatic (global CDN delivery) |

### Per-Tenant Billing Implementation

Cloudflare Stream has a **`creator` field** that can be used to associate tenant IDs:

1. **On upload**: Set `tenant_id` in the `creator` field
2. **For analytics**: Retrieve per-video usage via GraphQL Analytics API
3. **Aggregation**: Map video UID → MediaAsset → tenant_id for billing

### Available Metrics

#### Client-Side Metrics (`videoPlaybackEventsAdaptiveGroups`)
- `count`: View count
- `timeViewedMinutes`: Minutes viewed
- **Limitation**: Only available when using Stream Player

#### Server-Side Metrics (`streamMinutesViewedAdaptiveGroups`)
- `minutesViewed`: Delivered minutes (**the value used for billing**)
- **Feature**: Counts all HLS/DASH deliveries regardless of player type

## Architecture Proposal

### Asynchronous Upload Flow

S3 serves as the source of truth, with asynchronous transfer to Cloudflare.
This design prevents data inconsistencies even when Cloudflare uploads fail.

```
┌──────────────────────────────────────────────────────────────────┐
│                        Upload Flow                               │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Client                                                       │
│     │                                                            │
│     ▼                                                            │
│  2. Upload to S3 (existing flow)                                 │
│     │                                                            │
│     ▼                                                            │
│  3. Create MediaAsset                                            │
│     metadata: { cloudflare_sync_status: 'pending' }              │
│     │                                                            │
│     ▼                                                            │
│  4. Enqueue SyncVideoJob ────────────────────┐                   │
│     │                                        │                   │
│     ▼                                        ▼                   │
│  5. Return response (immediately)     6. Sidekiq Worker          │
│     * Served via CloudFront at           │                       │
│       this point                         ▼                       │
│                                    7. Generate signed URL        │
│                                       from S3                    │
│                                          │                       │
│                                          ▼                       │
│                                    8. Cloudflare Stream API      │
│                                       (copy from URL)            │
│                                          │                       │
│                                  ┌───────┴───────┐               │
│                                  ▼               ▼               │
│                               Success         Failure            │
│                                  │               │               │
│                                  ▼               ▼               │
│                           status:         Retry (max 5 times)    │
│                           'completed'            │               │
│                           cloudflare_uid         ▼               │
│                           saved           status: 'failed'       │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Playback Fallback

```
┌──────────────────────────────────────────────────────────────────┐
│                     Video Playback Flow                           │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  CloudflareStream::Uploader#playback_url(media_asset)            │
│     │                                                            │
│     ▼                                                            │
│  cloudflare_uid present?                                         │
│     │                                                            │
│     ├─── Yes ──▶ Cloudflare Stream HLS URL                      │
│     │           (subject to per-tenant billing)                  │
│     │                                                            │
│     └─── No ───▶ CloudFront signed URL                          │
│                 (fallback until sync completes or on failure)     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### System Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                          Backend                                 │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────┐    ┌──────────────────────────────┐    │
│  │ MediaAsset::         │    │ MediaAsset                   │    │
│  │ Uploader            │───▶│ metadata:                    │    │
│  │ (S3 upload)          │    │   - cloudflare_sync_status   │    │
│  └─────────────────────┘    │   - cloudflare_uid           │    │
│           │                 └──────────────────────────────┘    │
│           │ if video                                            │
│           ▼                                                      │
│  ┌─────────────────────┐                                        │
│  │ CloudflareStream::  │                                        │
│  │ SyncVideoJob        │──── S3 → Cloudflare Stream             │
│  │ (Sidekiq)           │     (retryable)                        │
│  └─────────────────────┘                                        │
│                                                                  │
│  ┌─────────────────────┐    ┌──────────────────────────────┐    │
│  │ CloudflareStream::  │───▶│ Monthly billing report        │    │
│  │ BillingCalculator   │    │ (per-tenant cost aggregation) │    │
│  └─────────────────────┘    └──────────────────────────────┘    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Sample Implementation

### 1. Video Upload Flow (Extending Existing Flow)

Simply using `MediaAsset::Uploader#upload` will automatically enqueue Cloudflare sync.

```ruby
# Existing upload process (no changes needed)
uploader = MediaAsset::Uploader.new
result = uploader.upload(file: uploaded_file, tenant_id: current_tenant.id)

# The returned MediaAsset contains the following metadata:
# - cloudflare_sync_status: 'pending' (for videos)
#
# CloudflareStream::SyncVideoJob runs in the background,
# and sets cloudflare_uid on success
```

### 2. Checking Sync Status

```ruby
media_asset = MediaAsset.find(id)

case media_asset.metadata['cloudflare_sync_status']
when CloudflareStream::SyncStatus::PENDING
  # Not yet started
when CloudflareStream::SyncStatus::PROCESSING
  # Sync in progress
when CloudflareStream::SyncStatus::COMPLETED
  # Sync complete - can deliver from Cloudflare Stream
  cloudflare_uid = media_asset.metadata['cloudflare_uid']
when CloudflareStream::SyncStatus::FAILED
  # Sync failed - fallback delivery from CloudFront
  error = media_asset.metadata['cloudflare_sync_error']
end
```

### 3. Getting Video Playback URL (with Fallback)

```ruby
uploader = CloudflareStream::Uploader.new
playback_url = uploader.playback_url(media_asset)

# Returns Cloudflare Stream HLS URL if cloudflare_uid exists,
# otherwise falls back to CloudFront signed URL
```

### 4. Manual Retry

```ruby
# Manually retry a failed sync
media_asset = MediaAsset.find(id)
if media_asset.metadata['cloudflare_sync_status'] == CloudflareStream::SyncStatus::FAILED
  # Reset status and re-enqueue job
  media_asset.update!(
    metadata: media_asset.metadata.merge(
      'cloudflare_sync_status' => CloudflareStream::SyncStatus::PENDING,
    ),
  )
  CloudflareStream::SyncVideoJob.perform_later(media_asset.id)
end
```

### 5. Generating Per-Tenant Billing Report

```ruby
# Monthly billing report job
class MonthlyBillingReportJob < ApplicationJob
  def perform(year, month)
    calculator = CloudflareStream::BillingCalculator.new
    costs = calculator.monthly_cost_by_tenant(year: year, month: month)

    costs.each do |tenant_id, data|
      BillingReport.create!(
        tenant_id: tenant_id,
        year: year,
        month: month,
        video_delivery_minutes: data[:delivery_minutes],
        video_storage_minutes: data[:storage_minutes],
        delivery_cost_usd: data[:delivery_cost_usd],
        storage_cost_usd: data[:storage_cost_usd],
        total_cost_usd: data[:total_cost_usd],
      )
    end
  end
end
```

### 6. Getting Video Playback URL

```ruby
# Video playback URL retrieval
class VideoPlaybackService
  def initialize(media_asset)
    @media_asset = media_asset
    @uploader = CloudflareStream::Uploader.new
  end

  def playback_url
    cloudflare_uid = @media_asset.metadata['cloudflare_uid']
    return nil unless cloudflare_uid

    @uploader.embed_url(cloudflare_uid)
  end

  def iframe_url
    cloudflare_uid = @media_asset.metadata['cloudflare_uid']
    return nil unless cloudflare_uid

    @uploader.iframe_url(cloudflare_uid)
  end
end
```

## Environment Variables

The following environment variables need to be configured:

```bash
# Cloudflare Stream
CLOUDFLARE_STREAM_ACCOUNT_ID=your_account_id
CLOUDFLARE_STREAM_API_TOKEN=your_api_token  # Requires Account Analytics permission
CLOUDFLARE_STREAM_CUSTOMER_SUBDOMAIN=your_subdomain  # e.g., a1b2c3d4
```

## Coexistence with Existing System

### Images Continue to Use CloudFront

```ruby
# Extending MediaAsset::Uploader
class MediaAsset::Uploader
  def upload(file:, tenant_id:)
    media_type = MediaAsset.detect_media_type(file.content_type)

    case media_type
    when :video
      # Via Cloudflare Stream
      upload_video_to_cloudflare(file, tenant_id)
    else
      # Existing S3 + CloudFront flow
      upload_to_s3(file, tenant_id)
    end
  end
end
```

## Considerations

### Advantages

1. **Per-tenant billing possible**: Tenant tracking via `creator` field
2. **Per-video usage tracking**: Detailed analytics via GraphQL API
3. **Automatic encoding**: Just upload and get HLS/DASH delivery
4. **Simple pricing structure**: Only two dimensions — storage + delivery
5. **No bandwidth concerns**: Delivery is billed by minutes, not bandwidth

### Disadvantages / Caveats

1. **No Ruby gem**: API must be called via direct HTTP requests (sample implementation provided)
2. **GraphQL API limitations**: Maximum queryable period is 1 month per query
3. **Client-side metrics limitation**: View counts unavailable without Stream Player
4. **Migration cost**: Existing videos need to be re-uploaded to Cloudflare Stream

### Recommendations

1. **Cloudflare Stream for new uploads only**: Keep existing videos on CloudFront for now
2. **Monthly batch billing**: Real-time tracking not required; aggregate via monthly job
3. **Use server-side metrics**: Use server-side delivered minutes for billing

## References

- [Cloudflare Stream Pricing](https://developers.cloudflare.com/stream/pricing/)
- [GraphQL Analytics API](https://developers.cloudflare.com/stream/getting-analytics/fetching-bulk-analytics/)
- [Manage creators](https://developers.cloudflare.com/stream/manage-video-library/creator-id/)
- [Direct creator uploads](https://developers.cloudflare.com/stream/uploading-videos/direct-creator-uploads/)

## Next Steps

1. [ ] Enable Stream feature in Cloudflare account
2. [ ] Generate API token (with Account Analytics permission)
3. [ ] Test upload/delivery with sample video
4. [ ] Test usage retrieval via GraphQL API
5. [ ] Develop phased production rollout plan
