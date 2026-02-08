# typed: strict

module Eventbridge
  class ProcessWorker
    extend T::Sig
    include Sidekiq::Job
    sidekiq_options queue: :default, retry: false, unique_for: 30.seconds, unique_until: :success

    sig { params(message_json: String).void }
    def perform(message_json)
      parsed_message = JSON.parse(message_json)
      message = Eventbridge::MessageParam.build_from_hash(parsed_message)
      processor = get_processor_for(message.source)
      processor&.process(message)
    end

    private

    sig { params(source: String).returns(T.nilable(Eventbridge::Processors::BaseProcessor)) }
    def get_processor_for(source)
      case source
      when %r{\Acom\.twogate\.idp/}
        Eventbridge::Processors::IdpTagProcessor.new
      end
    end
  end
end
