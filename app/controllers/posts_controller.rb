class PostsController < ApplicationController
  before_action :set_post, only: %i[show destroy]
  before_action :authenticate_user!, only: %i[create destroy show]

  def index
    @posts = Post.includes(:user).order(created_at: :desc).limit(50)

    return unless @posts.present?

    first_post_date = @posts.first.created_at.in_time_zone('Tokyo').to_date
    today = Time.now.to_date
    @today_post = (first_post_date == today)
  end

  def show; end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.name = current_user.name

    if @post.save
      @post.broadcast_prepend_later_to('posts_channel')
      @post_content = @post.option == '0' ? '本日も張り切って！' : '本日はこの辺で'
      flash.now[:notice] = '投稿しました'
    else
      flash[:alert] = '投稿に失敗しました'
      redirect_to posts_path, status: :unprocessable_entity
    end
  end

  def destroy
    check_user(@post)
    @post.destroy!
    redirect_to posts_path, status: :see_other, notice: '削除しました'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:option)
  end

  def check_user(post)
    return unless post.user_id != current_user.id

    redirect_to posts_path, notice: '不正なアクセスです'
  end
end
