# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  it 'loads without errors' do
    expect(described_class).to be < ActionController::Base
  end
end