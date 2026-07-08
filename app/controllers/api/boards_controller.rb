module Api
  class BoardsController < BaseController
    before_action :authenticate!, only: :create

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

    # POST /api/boards  (auth) — creates a board under the user's organization.
    def create
      organization = current_user.organizations.first
      return render json: { error: "No organization" }, status: :unprocessable_content unless organization

      board = organization.boards.new(board_params)
      board.save!
      render json: board_json(board), status: :created
    end

    private

    def board_params
      params.require(:board).permit(:name, :is_public)
    end
  end
end
