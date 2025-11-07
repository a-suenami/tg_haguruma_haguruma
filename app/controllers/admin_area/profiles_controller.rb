# typed: strict
# frozen_string_literal: true

module AdminArea
  class ProfilesController < ApplicationController
    extend T::Sig

    sig { void }
    def edit
      @admin = T.let(current_admin, T.nilable(Admin))
      @auth0_account = T.let(@admin&.auth0_account, T.nilable(Auth0Account))
    end

    sig { void }
    def update
      result = AdminArea::Profiles::UpdateService.new(
        email: profile_params[:email],
        password: profile_params[:password],
      ).execute(T.must(current_admin))

      if result.is_a?(Mangrove::Result::Ok)
        redirect_to edit_admin_area_profiles_path, notice: t('helpers.messages.updated')
      else
        # Reload admin from DB to get fresh data
        # (bypassing current_admin cache which may have been mutated by service)
        @admin = T.let(
          Admin.includes(:auth0_account).find_by(id: session[:admin_id]),
          T.nilable(Admin),
        )
        @auth0_account = T.let(@admin&.auth0_account, T.nilable(Auth0Account))
        @error_message = T.let(result.err_inner.join(', '), T.nilable(String))
        render :edit, status: :unprocessable_content
      end
    end

    private

    sig { returns(ActionController::Parameters) }
    def profile_params
      T.cast(params.require(:profile), ActionController::Parameters).permit(:email, :password)
    end
  end
end
