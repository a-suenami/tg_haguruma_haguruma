# ==============================================================================
# spec - helpers - recaptcha enterprise helper
# ==============================================================================
require 'google/cloud/recaptcha_enterprise/v1'

module RecaptchaEnterpriseHelper
  extend ActiveSupport::Concern

  included do
    let(:captcha_token) { 'captcha_token' }

    let(:captcha_validity) { true }
    let(:captcha_action) { 'checkout' }
    let(:captcha_invalid_reason) { :INVALID_REASON_UNSPECIFIED }
    let(:captcha_score) { 0.7 }

    # OPTIMIZE: Use verified doubles
    # rubocop:disable RSpec/VerifiedDoubles
    let(:recaptcha_double) { double(Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client) }
    let(:assessment_double) { double(Google::Cloud::RecaptchaEnterprise::V1::Assessment) }
    let(:token_properties_double) { double(Google::Cloud::RecaptchaEnterprise::V1::TokenProperties) }
    let(:risk_analysis_double) { double(Google::Cloud::RecaptchaEnterprise::V1::RiskAnalysis) }
    # rubocop:enable RSpec/VerifiedDoubles

    before do
      RSpec::Sorbet.allow_doubles!

      allow_any_instance_of(Tenant).to receive(:google_cloud_service_account).and_return('{}')
      allow_any_instance_of(Tenant).to receive(:google_cloud_project_id).and_return('this_is_google_cloud_project_id')
      allow_any_instance_of(Tenant).to receive(:recaptcha_enterprise_score_based_site_key).and_return('this_is_recaptcha_enterprise_score_based_site_key')
      allow_any_instance_of(Tenant).to receive(:recaptcha_enterprise_checkbox_site_key).and_return('this_is_recaptcha_enterprise_checkbox_site_key')
      allow_any_instance_of(Tenant).to receive(:enable_recaptcha_enterprise?).and_return(true)

      allow(Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client).to receive(:new).and_return(recaptcha_double)
      allow(recaptcha_double).to receive(:create_assessment).and_return(assessment_double)
      allow(assessment_double).to receive(:token_properties).and_return(token_properties_double)
      allow(assessment_double).to receive(:risk_analysis).and_return(risk_analysis_double)
      allow(token_properties_double).to receive(:valid).and_return(captcha_validity)
      allow(token_properties_double).to receive(:action).and_return(captcha_action)
      allow(token_properties_double).to receive(:invalid_reason).and_return(captcha_invalid_reason)
      allow(risk_analysis_double).to receive(:score).and_return(captcha_score)
    end
  end
end
