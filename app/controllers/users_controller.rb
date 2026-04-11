class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :set_user

  def show
    @public_recipes = @user.recipes.public_recipes.recent.page(params[:page])
    @followers_count = @user.followers.count
    @following_count = @user.following.count
  end

  def edit
    redirect_to root_path, alert: 'Not authorized.' unless @user == current_user
  end

  def update
    redirect_to root_path, alert: 'Not authorized.' unless @user == current_user

    if @user.update(user_params)
      redirect_to @user, notice: 'Profile updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :username, :bio, :avatar)
  end
end
