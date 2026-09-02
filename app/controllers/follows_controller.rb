class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def create
    unless current_user.following?(@user)
      current_user.follows_as_follower.create!(following: @user)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user }
    end
  end

  def destroy
    follow = current_user.follows_as_follower.find_by(following: @user)
    follow&.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @user }
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
