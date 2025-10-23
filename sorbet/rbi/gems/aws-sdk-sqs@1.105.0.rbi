# typed: strong

# Manual RBI for aws-sdk-sqs
# AWS SDK gems use lazy loading which prevents Tapioca from generating RBIs automatically

module Aws
  module SQS
    class Client
      sig { params(options: T.untyped).void }
      def initialize(**options); end

      sig { params(params: T.untyped).returns(T.untyped) }
      def get_queue_url(params = {}); end

      sig { params(params: T.untyped).returns(T.untyped) }
      def receive_message(params = {}); end

      sig { params(params: T.untyped).returns(T.untyped) }
      def delete_message(params = {}); end
    end

    class QueuePoller
      sig { params(queue_url: String, options: T.untyped).void }
      def initialize(queue_url, **options); end

      sig { params(options: T.untyped, block: T.proc.params(messages: T.untyped).void).void }
      def poll(**options, &block); end
    end
  end
end
