module Api
  # Shared base for the JSON API: consistent error responses and helpers.
  class BaseController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
    end

    private

    # Small hand-written serializers. A real app might use a gem
    # (jbuilder / active_model_serializers); kept explicit here so the
    # JSON shape is obvious and matches the Django API.
    def board_json(board)
      { id: board.id, name: board.name, slug: board.slug, is_public: board.is_public }
    end

    def post_json(post)
      {
        id: post.id,
        board_id: post.board_id,
        title: post.title,
        body: post.body,
        status: post.status,
        vote_count: post.vote_count,
        comment_count: post.comments.count,
        created_at: post.created_at
      }
    end

    def comment_json(comment)
      { id: comment.id, post_id: comment.post_id, body: comment.body, created_at: comment.created_at }
    end
  end
end
