class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[show]

  def show
    @user = User.find_by(id: params[:id])

    if @user.nil?
      redirect_to posts_path, notice: 'ユーザーが見つかりません'
      return
    end

    check_user(@user)
    @user_posts = @user.posts.order(created_at: :desc)

    return unless @user_posts.present?

    first_post_date = @user_posts.first.created_at.in_time_zone('Tokyo').to_date
    today = Time.now.to_date
    @today_post = (first_post_date == today)
  end

  private

  def check_user(user)
    return if user.id == current_user.id

    redirect_to user_path(current_user), notice: '自分のページ以外は閲覧できません'
  end
end
