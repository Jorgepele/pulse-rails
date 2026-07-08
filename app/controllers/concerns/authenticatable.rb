# Token authentication shared by the API controllers. Reads the token from
# an `Authorization: Token <token>` header (same scheme as the Django API).
module Authenticatable
  extend ActiveSupport::Concern

  # Sets @current_user if a valid token is present; does not fail if absent.
  def current_user
    return @current_user if defined?(@current_user)

    header = request.headers["Authorization"].to_s
    token = header.start_with?("Token ") ? header.split(" ", 2).last : nil
    @current_user = token && User.find_by(token: token)
  end

  # Use as a before_action to require authentication on write endpoints.
  def authenticate!
    return if current_user

    render json: { error: "Authentication required" }, status: :unauthorized
  end
end
