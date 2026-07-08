module Api
  class BoardsController < BaseController
    # GET /api/boards
    def index
      boards = Board.where(is_public: true).order(:name)
      render json: boards.map { |b| board_json(b) }
    end

    # GET /api/boards/:id
    def show
      board = Board.find(params[:id])
      render json: board_json(board)
    end
  end
end
