# typed: strict

module Eventbridge
  class PollService
    extend T::Sig

    sig { void }
    def initialize
      client = T.let(Aws::SQS::Client.new(region: Settings.aws.sqs.region), Aws::SQS::Client)
      queue_url = client.get_queue_url(queue_name: Settings.aws.sqs.event_queue_name).queue_url
      @poller = T.let(Aws::SQS::QueuePoller.new(queue_url, client:), Aws::SQS::QueuePoller)
    end

    # ポールするレイヤーはできるだけ薄く軽くする
    sig { void }
    def execute
      Rails.logger.info('Polling SQS queue...')
      @poller.poll(wait_time_seconds: 20, visibility_timeout: 10, max_number_of_messages: 10) do |messages|
        messages.each do |message|
          # パフォーマンス上 JSON parse せず validation もせずにそのまま渡す
          Eventbridge::ProcessWorker.perform_async(message.body)
        end
      end
    end
  end
end
