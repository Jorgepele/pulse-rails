module Api
  class AuthController < BaseController
    before_action :authenticate!, only: :me

    # POST /api/auth/register
    # Creates the user together with a personal organization they own, so
    # every account has a tenant to create boards under (multi-tenant core).
    def register
      user = User.new(email: params[:email], password: params[:password])
      ActiveRecord::Base.transaction do
        user.save!
        org = Organization.create!(name: "#{user.email}'s workspace", owner: user)
        org.memberships.create!(user: user, role: "owner")
      end
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
