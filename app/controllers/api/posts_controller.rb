module Api
  class PostsController < BaseController
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
      post.save!
      render json: post_json(post), status: :created
    end

    # POST /api/posts/:id/vote  — adds the voter's vote, or removes it if it
    # already exists (toggle). Mirrors the Django vote-toggle endpoint.
    def vote
      post = Post.find(params[:id])
      token = params.require(:voter_token)

      existing = post.votes.find_by(voter_token: token)
      if existing
        existing.destroy
        voted = false
      else
        post.votes.create!(voter_token: token)
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
