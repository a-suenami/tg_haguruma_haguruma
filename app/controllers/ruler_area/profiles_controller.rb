# typed: strict
# frozen_string_literal: true

module RulerArea
  class ProfilesController < ApplicationController
    extend T::Sig

    sig { void }
    def edit
      @ruler = T.let(current_ruler, T.nilable(Ruler))
      @auth0_account = T.let(@ruler&.auth0_accounts&.first, T.untyped)
    end

    sig { void }
    def update
      result = RulerArea::Profiles::UpdateService.new(
        email: profile_params[:email],
        password: profile_params[:password],
      ).execute(current_ruler)

      if result.success?
        redirect_to edit_ruler_area_profiles_path, notice: t('helpers.messages.updated')
      else
        # Reload ruler from DB to get fresh data
        # (bypassing current_ruler cache which may have been mutated by service)
        @ruler = T.let(
          Ruler.includes(:auth0_accounts).find_by(id: session[:ruler_id]),
          T.nilable(Ruler),
        )
        @auth0_account = T.let(@ruler&.auth0_accounts&.first, T.untyped)
        @error_message = T.let(result.errors.join(', '), T.nilable(String))
        render :edit, status: :unprocessable_entity
      end
    end

    private

    sig { returns(ActionController::Parameters) }
    def profile_params
      T.cast(params.require(:profile), ActionController::Parameters).permit(:email, :password)
    end
  end
end
