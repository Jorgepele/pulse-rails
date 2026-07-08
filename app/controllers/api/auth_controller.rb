module Api
  class AuthController < BaseController
    before_action :authenticate!, only: :me

    # POST /api/auth/register
    def register
      user = User.new(email: params[:email], password: params[:password])
      user.save!
      render json: user_json(user), status: :created
    end

    # POST /api/auth/login
    def login
      user = User.find_by(email: params[:email].to_s.strip.downcase)
      if user&.authenticate(params[:password])
        render json: user_json(user)
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end

    # GET /api/auth/me
    def me
      render json: user_json(current_user)
    end
  end
end
