# typed: strict

# ==============================================================================
# config - initializers - 000 sidekiq status
# ==============================================================================
module Sidekiq::Status
  extend T::Sig

  class Status < T::Enum
    enums do
      Queued = new('queued')
      Working = new('working')
      Complete = new('complete')
      Failed = new('failed')
      Interrupted = new('interrupted')
    end
  end

  sig { params(jid: T.nilable(String)).returns(T.nilable(Status)) }
  def self.typed_status(jid)
    status = status(jid)

    case status
    when :queued
      Status::Queued
    when :working
      Status::Working
    when :complete
      Status::Complete
    when :failed
      Status::Failed
    when :interrupted
      Status::Interrupted
    end
  end
end