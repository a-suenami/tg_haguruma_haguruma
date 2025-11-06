# typed: strong

# Manual RBI for aws-sdk-eventbridge
# AWS SDK gems use lazy loading which prevents Tapioca from generating RBIs automatically

module Aws
  module EventBridge
    class Client
      sig { params(options: T.untyped).void }
      def initialize(**options); end

      sig { params(params: T.untyped).returns(T.untyped) }
      def put_events(params = {}); end
    end
  end
end
