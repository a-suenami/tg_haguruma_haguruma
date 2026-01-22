# frozen_string_literal: true

Rails.application.routes.draw do
  # ============================================================================
  # Common routes (all domains)
  # ============================================================================
  get 'health_check' => 'rails/health#show', as: :rails_health_check

  # API routes
  draw :'api/v1/auth'
  draw :api

  # Test routes (only available in test environment or when ALLOW_AUTH_BYPASS is enabled)
  if Rails.env.test? || Rails.env.development? || ENV['ALLOW_AUTH_BYPASS'] == 'true'
    namespace :test do
      get 'auth/bypass', to: 'auth#bypass'
    end
  end

  # ============================================================================
  # Ruler Area (ruler domain only)
  # ============================================================================
  constraints Constraints::RulerDomainConstraint.new do
    draw :ruler
  end

  # ============================================================================
  # Admin Area ({tenant_id}.admin.{base} domain only)
  # ============================================================================
  constraints Constraints::AdminDomainConstraint.new do
    draw :admin
  end

  # ============================================================================
  # User Area (tenant's user_page_domain only)
  # ============================================================================
  constraints Constraints::UserAreaDomainConstraint.new do
    draw :user_area
  end
end
