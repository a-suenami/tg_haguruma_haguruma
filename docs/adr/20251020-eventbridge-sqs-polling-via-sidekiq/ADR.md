# ADR: Processing EventBridge Events via SQS Polling Through Sidekiq

- **Date**: 2025-10-20 (retroactively recorded on 2026-02-11)
- **Status**: Decided
- **Decision Makers**: Akira Suenami, Daichi Miyazaki

## Context

The Rails application needs to receive and process events sent from EventBridge (such as IdP user operations). Events from EventBridge are delivered to an SQS queue, and the application-side architecture for polling and processing these events was under consideration.

Two approaches were considered:

1. **Implement a direct consumer using the SQS client library** — Receive messages from SQS and process them in place
2. **Receive messages from SQS and enqueue them as Sidekiq jobs** — Separate the polling layer from the processing layer

## Decision

Adopt the **SQS polling → Sidekiq enqueue** architecture.

### Architecture

```
EventBridge → SQS Queue → [Eventbridge::PollService] → Sidekiq → [Eventbridge::ProcessWorker]
```

- `Eventbridge::PollService` (launched via `bin/eventbridge_poller`) long-polls the SQS queue
- Received messages are passed directly to `Eventbridge::ProcessWorker.perform_async` without JSON parsing or validation
- `Eventbridge::ProcessWorker` (Sidekiq job) handles the actual event parsing, dispatching, and processing

### Polling Layer Design Principle

The polling layer is kept as thin and lightweight as possible. It does not concern itself with message contents and limits its responsibility to relaying messages to Sidekiq.

```ruby
# app/services/eventbridge/poll_service.rb
@poller.poll(wait_time_seconds: 20, visibility_timeout: 10, max_number_of_messages: 10) do |messages|
  messages.each do |message|
    Eventbridge::ProcessWorker.perform_async(message.body)
  end
end
```

### Deployment Architecture

SQS polling runs as a dedicated ECS service (`haguruma-main-service-eventbridge-poller-{env}`), separate from the Sidekiq worker service. It has lightweight resource requirements (cpu: 256, memory: 512).

## Rationale

### Consolidating Async Processing in Sidekiq

The application uses Sidekiq as its standard async processing platform. By routing EventBridge event processing through Sidekiq:

- **Retry mechanism**: Sidekiq's built-in retry with exponential backoff and Dead Job Queue can be used as-is
- **Unified monitoring**: Job status can be monitored through Sidekiq Web UI and existing monitoring infrastructure
- **Queue priority control**: Integration with existing queue priority settings (`realtime_priority`, `high_priority`, `default`, `low_priority`)
- **Tenant context management**: Leverages existing Sidekiq-specific infrastructure such as automatic cleanup via the `request_store-sidekiq` gem

### Why Direct SQS Consumer Was Not Chosen

While processing directly with the SQS client would be architecturally simpler:

- Custom retry and error handling mechanisms would need to be implemented
- Separate monitoring and visibility tooling would be required
- Infrastructure overlapping with existing Sidekiq-oriented systems (such as tenant context management) would need to be built

## Impact

- A separate ECS service must be operated for SQS polling
- If the Sidekiq worker service is down, polled messages will not be processed
- The SQS → Sidekiq relay adds slight latency to message processing (acceptable for async processing)

## Related

- `app/services/eventbridge/poll_service.rb` — SQS polling implementation
- `app/jobs/eventbridge/process_worker.rb` — Event processing as a Sidekiq job
- `bin/eventbridge_poller` — Polling process startup script
- `ecspresso/{stg,prod}/services/eventbridge_poller/` — ECS service definitions
- [ADR: Safety of Tenant Context Management in Sidekiq Jobs](../20260209-tenant-context-management-in-sidekiq/ADR.md) — Related subsequent decision
