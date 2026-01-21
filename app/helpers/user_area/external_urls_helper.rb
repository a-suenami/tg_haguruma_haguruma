# frozen_string_literal: true

module UserArea
  module ExternalUrlsHelper
    def sns_x_url
      'https://x.com/_yokikoto_kiku_'
    end

    def sns_instagram_url
      'https://www.instagram.com/onoekikugoro/'
    end

    def terms_of_service_url
      'https://www.officialgoods.site/2ee8bbc2204280feb624c56374cccb53?pvs=74'
    end

    def privacy_policy_url
      'https://www.officialgoods.site/2ee8bbc2204280feb624c56374cccb53?pvs=74'
    end

    def legal_notice_url
      'https://officialgoods.notion.site/2ee8bbc2204280f4a5bddee3b56d4cab?pvs=73'
    end

    def faq_url
      'https://officialgoods.notion.site/2ee8bbc22042804787c5c9c7c7c9fea4?pvs=74'
    end

    def contact_url
      'https://agrain.jp/#inquiry'
    end

    def idp_mypage_url
      oauth_provider = current_tenant&.oauth_provider
      return nil unless oauth_provider

      "#{oauth_provider.endpoint_base}/my"
    end
  end
end
