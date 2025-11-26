class UsersController < ApplicationController
  before_action :set_user

  def edit_password
    # Show password change form
  end

  def update_password
    if @user.authenticate(params[:current_password])
      if params[:password] == params[:password_confirmation]
        if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
          redirect_to root_path, notice: "Password updated successfully!"
        else
          flash.now[:alert] = @user.errors.full_messages.join(", ")
          render :edit_password, status: :unprocessable_entity
        end
      else
        flash.now[:alert] = "New password and confirmation do not match"
        render :edit_password, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Current password is incorrect"
      render :edit_password, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end
end
