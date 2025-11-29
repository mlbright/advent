class UsersController < ApplicationController
  before_action :set_user, only: [ :edit_password, :update_password ]
  before_action :require_admin, only: [ :index, :new, :create, :destroy ]

  def index
    @users = User.order(created_at: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "User created successfully!"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user == current_user
      redirect_to users_path, alert: "You cannot delete your own account."
      return
    end

    @user.destroy
    redirect_to users_path, notice: "User deleted successfully!"
  end

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

  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "You must be an admin to access this page."
    end
  end

  def user_params
    permitted = [ :email, :password, :password_confirmation ]
    permitted << :admin if current_user&.admin?
    params.require(:user).permit(permitted)
  end
end
