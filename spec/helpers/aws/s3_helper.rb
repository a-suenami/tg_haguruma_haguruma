# typed: strict

# ==============================================================================
# spec - helpers - aws - s3 helper
# ==============================================================================
module Aws::S3Helper
  extend ActiveSupport::Concern

  T.bind(self, T.untyped)

  included do
    T.bind(self, T.untyped)

    before do
      allow_any_instance_of(Aws::S3::Bucket).to receive(:put_object).and_wrap_original do |_original_method, *_args|
        Aws::S3::Object.allocate
      end
    end
  end
end
