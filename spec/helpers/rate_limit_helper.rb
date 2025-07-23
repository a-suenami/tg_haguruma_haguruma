module RateLimitHelper
  extend ActiveSupport::Concern

  included do
    shared_examples 'throttling by rate limit' do
      context 'when rate limit is exceeded' do
        before do
          allow_any_instance_of(::API::ApplicationController).to receive(:rate_limit_per_endpoint!).and_raise(AppError::TooBusy)
        end

        it 'return too many requests error' do
          expect(subject).to eq_status 429
          expect(JSON.parse(response.body, symbolize_names: true)).to include({
            error: {
              type: 'too_many_requests',
              message: '現在大変混み合っております。時間をおいて再度お試しください。',
            },
          })
        end
      end
    end
  end
end
