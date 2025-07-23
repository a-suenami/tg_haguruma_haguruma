# ==============================================================================
# spec/helpers/entry_helper.rb
# ==============================================================================
module EntryHelper
  extend ActiveSupport::Concern

  included do
    shared_examples 'available_until_days_before examples for preview' do
      let(:payment_method_class) { PaymentCore::KomojuPayment::KonbiniSevenElevenV1 }
      let(:payment_method_code_param) { payment_method_class.code }
      let(:entry_period_ends_at) { Time.zone.parse('2024-01-10 23:00:00') }
      # 以下2つを integer で定義すること
      let(:available_until_days_before) { nil }
      let(:now_days_before) { nil }

      before do
        reception.update!(entry_period_starts_at: entry_period_ends_at.ago(10.days), entry_period_ends_at:)
        payment_method_name = T.let(reception, Reception).payment_method_names.find_by(payment_method_name: payment_method_class.to_s)
        payment_method_name = T.must(payment_method_name)
        payment_method_name.update!(available_until_days_before:)
      end

      shared_examples 'success' do
        it 'success' do
          travel_to (entry_period_ends_at.to_date - now_days_before.days).beginning_of_day do
            is_expected.to eq_status 200 # rubocop:disable RSpec/ImplicitSubject
          end
        end
      end

      shared_examples 'return error' do
        it 'return error' do
          travel_to (entry_period_ends_at.to_date - now_days_before.days).beginning_of_day do
            is_expected.to eq_status 400 # rubocop:disable RSpec/ImplicitSubject

            expect(JSON.parse(response.body, symbolize_names: true)).to include({
              error: {
                type: 'invalid_request_error', code: 'validation_error', message: 'エラーが発生しました',
                params: {
                  messages: {
                    payment_method_code: ['現在ご指定の決済方法はご利用いただけません。'],
                  },
                  details: {
                    payment_method_code: [{ error: 'unavailable_now' }],
                  },
                },
              },
            })
          end
        end
      end

      context 'when available_until_days_before is 0' do
        let(:available_until_days_before) { 0 }

        context 'when now is 3 days before the entry_period_ends_at' do
          let(:now_days_before) { 3 }

          it_behaves_like 'success'
        end

        context 'when now is the day of the entry_period_ends_at' do
          let(:now_days_before) { 0 }

          it_behaves_like 'success'
        end
      end

      context 'when available_until_days_before is 3' do
        let(:available_until_days_before) { 3 }

        context 'when now is 4 days before the entry_period_ends_at' do
          let(:now_days_before) { 4 }

          it_behaves_like 'success'
        end

        context 'when now is 3 days before the entry_period_ends_at' do
          let(:now_days_before) { 3 }

          it_behaves_like 'success'
        end

        context 'when now is 2 days before the entry_period_ends_at' do
          let(:now_days_before) { 2 }

          it_behaves_like 'return error'
        end


        context 'when now is the day of the entry_period_ends_at' do
          let(:now_days_before) { 0 }

          it_behaves_like 'return error'
        end
      end
    end
  end
end
