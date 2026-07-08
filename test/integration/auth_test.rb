require "test_helper"

class AuthTest < ActionDispatch::IntegrationTest
  test "register creates a user and returns a token" do
    assert_difference "User.count", 1 do
      post "/api/auth/register", params: { email: "new@example.com", password: "secret123" }
    end
    assert_response :created
    assert JSON.parse(response.body)["token"].present?
  end

  test "register also creates a personal organization owned by the user" do
    assert_difference [ "Organization.count", "Membership.count" ], 1 do
      post "/api/auth/register", params: { email: "founder@example.com", password: "secret123" }
    end
    user = User.find_by(email: "founder@example.com")
    org = user.organizations.first
    assert_equal user, org.owner
    assert_equal "owner", user.memberships.first.role
  end

  test "register rejects a bad email" do
    post "/api/auth/register", params: { email: "nope", password: "secret123" }
    assert_response :unprocessable_content
  end

  test "login returns the token for valid credentials" do
    post "/api/auth/login", params: { email: "jorge@example.com", password: "secret123" }
    assert_response :success
    assert_equal "jorge-token", JSON.parse(response.body)["token"]
  end

  test "login rejects a wrong password" do
    post "/api/auth/login", params: { email: "jorge@example.com", password: "wrong" }
    assert_response :unauthorized
  end

  test "me requires a token" do
    get "/api/auth/me"
    assert_response :unauthorized
  end

  test "me returns the current user with a valid token" do
    get "/api/auth/me", headers: { "Authorization" => "Token jorge-token" }
    assert_response :success
    assert_equal "jorge@example.com", JSON.parse(response.body)["email"]
  end
end
