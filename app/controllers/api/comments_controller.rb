module Api
  class CommentsController < BaseController
    before_action :authenticate!, only: :create

    # GET /api/comments?post=:id
    def index
      comments = visible_comments
      comments = comments.where(post_id: params[:post]) if params[:post].present?
      render json: comments.map { |c| comment_json(c) }
    end

    # POST /api/comments — only on a post whose board the user can see.
    def create
      raise ActiveRecord::RecordNotFound, "Post not found" unless
        Post.where(board: visible_boards).exists?(id: comment_params[:post_id])

      comment = Comment.new(comment_params)
      comment.author = current_user
      comment.save!
      render json: comment_json(comment), status: :created
    end

    private

    # Comments inherit the visibility of their post's board.
    def visible_comments
      Comment.where(post: Post.where(board: visible_boards))
    end

    def comment_params
      params.require(:comment).permit(:post_id, :body)
    end
  end
end
