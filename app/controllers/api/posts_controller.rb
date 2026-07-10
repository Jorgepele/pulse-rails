module Api
  class PostsController < BaseController
    before_action :authenticate!, only: [ :create, :vote ]

    # GET /api/posts  (optionally ?board_id= and/or ?status=)
    def index
      posts = visible_posts_for_list
      posts = posts.where(board_id: params[:board_id]) if params[:board_id].present?
      posts = posts.where(status: params[:status]) if params[:status].present?
      render json: posts.map { |p| post_json(p) }
    end

    # GET /api/posts/:id
    def show
      post = visible_posts.find(params[:id])
      render json: post_json(post)
    end

    # POST /api/posts — only on a board the user can see.
    def create
      raise ActiveRecord::RecordNotFound, "Board not found" unless
        visible_boards.exists?(id: post_params[:board_id])

      post = Post.new(post_params)
      post.author = current_user
      post.save!
      render json: post_json(post), status: :created
    end

    # POST /api/posts/:id/vote  — adds the current user's vote, or removes it
    # if it already exists (toggle). Mirrors the Django vote-toggle endpoint.
    def vote
      post = visible_posts.find(params[:id])

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

    # Posts inherit their board's visibility.
    def visible_posts
      Post.where(board: visible_boards)
    end

    # Preloads the associations the JSON needs, so serializing a page of posts
    # costs a fixed number of queries instead of one per post (N+1).
    def visible_posts_for_list
      visible_posts.includes(:author, :votes, :comments)
    end

    def post_params
      params.require(:post).permit(:board_id, :title, :body, :status)
    end
  end
end
