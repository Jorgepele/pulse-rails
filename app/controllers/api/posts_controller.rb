module Api
  class PostsController < BaseController
    before_action :authenticate!, only: [ :create, :vote ]

    # GET /api/posts  (optionally ?board_id=)
    def index
      posts = Post.all
      posts = posts.where(board_id: params[:board_id]) if params[:board_id].present?
      render json: posts.map { |p| post_json(p) }
    end

    # GET /api/posts/:id
    def show
      post = Post.find(params[:id])
      render json: post_json(post)
    end

    # POST /api/posts
    def create
      post = Post.new(post_params)
      post.author = current_user
      post.save!
      render json: post_json(post), status: :created
    end

    # POST /api/posts/:id/vote  — adds the current user's vote, or removes it
    # if it already exists (toggle). Mirrors the Django vote-toggle endpoint.
    def vote
      post = Post.find(params[:id])

      existing = post.votes.find_by(user: current_user)
      if existing
        existing.destroy
        voted = false
      else
        post.votes.create!(user: current_user)
        voted = true
      end

      render json: { voted: voted, vote_count: post.vote_count }
    end

    private

    def post_params
      params.require(:post).permit(:board_id, :title, :body, :status)
    end
  end
end
