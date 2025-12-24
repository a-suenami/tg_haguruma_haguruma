# typed: true
# frozen_string_literal: true

module UserArea
  class ProfilesController < ApplicationController
    extend T::Sig

    # GET /profile
    sig { void }
    def show
      @user = current_user
    end

    # GET /profile/edit
    sig { void }
    def edit
      @user = current_user
    end

    # PATCH /profile
    sig { void }
    def update
      @user = current_user

      if @user&.update(user_params)
        redirect_to user_area_profile_path, notice: 'Profile updated successfully'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    sig { returns(ActionController::Parameters) }
    def user_params
      params.require(:user).permit(:uid)
    end
  end
end
