# typed: strict

# ==============================================================================
# spec - helpers - qkeys helper
# ==============================================================================
module QkeysHelper
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { Kernel }

  included do
    extend T::Sig

    T.bind(self, T.untyped)

    before do
      allow(QkeysRecord).to receive(:request).and_wrap_original do |_original_method, args|
        http_method = args[:http_method]
        path = args[:path]
        body = args[:body]

        self.qkeys_record_request(http_method, path, body)
      end
    end

    sig { params(http_method: Triple::HTTPMethod, path: String, body: T::Hash[Symbol, T.untyped]).returns(Faraday::Response) }
    def qkeys_record_request(http_method, path, body)
      body # 今のところ使用しない

      case path
      when '/elementary-generator/SqrcController'
        case http_method
        when Triple::HTTPMethod::POST
          base64_image = <<~IMAGE
            iVBORw0KGgoAAAANSUhEUgAAAIQAAACEAQAAAAB5P74KAAAA+UlEQVR42s2WwW3F
            MAxDuYH235IbqCLl39/2FrpAayCB8w62TFFy0D8G8ccEQDWrujyNSXXPJ5rtaU6g
            VYuDNL0irIl08C0Bf4HoeOKKtHMiuc/4kovn5OUASf/NGw+JllwjlEKNCdZMxKp3
            QbCivxWLCPWWF7QD+oaME9pWQOfkUBESOZllaxNIa58SSnModzyOConkprM48IK4
            Wrz+OWlGSpHRTgD37BGZ715Up1IyIj+1nQDg7JUQDVW/+y1y4rTVy6E5cZm5Y6tx
            d062sfkiqs8bJCPKoWIE+opMiHQzee/1nOhGpPsStpNkRMrPw+0AFZP/9d/yAa52
            znkq5mZ7AAAAAElFTkSuQmCC
          IMAGE
          Faraday::Response.new({ status: 200, body: Base64.decode64(base64_image) })
        else
          raise NotImplementedError
        end
      else
        raise NotImplementedError
      end
    end
  end
end
