# ==============================================================================
# spec - helpers - api helper
# ==============================================================================
module APIHelper
  extend ActiveSupport::Concern

  shared_examples 'under READ_ONLY_MODE is true' do
    before do
      allow(Settings).to receive(:read_only_mode).and_return(true)
    end

    it 'return message' do
      is_expected.to eq 400 # rubocop:disable RSpec/ImplicitSubject

      expect(JSON.parse(response.body, symbolize_names: true)).to eq(
        {
          error: {
            type: 'invalid_request_error',
            code: 'invalid_request',
            message: '時間をおいて再度お試しください。',
          },
        },
      )
    end
  end
end
