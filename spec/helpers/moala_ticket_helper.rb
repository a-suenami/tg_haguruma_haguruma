# typed: true

# ==============================================================================
# spec - helpers - moala ticket helper
# ==============================================================================
module MoalaTicketHelper
  extend ActiveSupport::Concern

  included do
    T.bind(self, T.untyped)

    let(:mock_connection) { Faraday::Connection.new }

    before do
      allow_any_instance_of(Tenant).to receive(:moala_ticket_api_key).and_return('this_is_moala_ticket_api_key')

      allow(Faraday).to receive(:new).and_return(mock_connection)
      allow(mock_connection).to receive(:post).with(%r{/api/v1/events}, be_a(Hash)).and_wrap_original do |_original_method, _params|
        Faraday::Response.new(
          status: 201,
          body: File.read("#{Rails.root}/spec/fixtures/moala_ticket/event.json"),
        )
      end
      allow(mock_connection).to receive(:post).with(%r{/api/v1/grades}, be_a(Hash)).and_wrap_original do |_original_method, _params|
        Faraday::Response.new(
          status: 201,
          body:  File.read("#{Rails.root}/spec/fixtures/moala_ticket/grade.json"),
        )
      end
      allow(mock_connection).to receive(:post).with(%r{/api/v1/books}, be_a(Hash)).and_wrap_original do |_original_method, _params|
        moala_ticket_book_response_body = File.read("#{Rails.root}/spec/fixtures/moala_ticket/book.json")
        response_body = JSON.parse(moala_ticket_book_response_body)
        response_body['identifier'] = SecureRandom.uuid

        Faraday::Response.new(
          status: 201,
          body: response_body.to_json,
        )
      end
    end
  end
end
