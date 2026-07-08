module Api
  class CommentsController < BaseController
    before_action :authenticate!, only: :create

    # GET /api/comments?post=:id
    def index
      comments = Comment.all
      comments = comments.where(post_id: params[:post]) if params[:post].present?
      render json: comments.map { |c| comment_json(c) }
    end

    # POST /api/comments
    def create
      comment = Comment.new(comment_params)
      comment.author = current_user
      comment.save!
      render json: comment_json(comment), status: :created
    end

    private

    def comment_params
      params.require(:comment).permit(:post_id, :body)
    end
  end
end
