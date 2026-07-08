require "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  # Authenticated requests send the fixture user's token.
  def auth
    { "Authorization" => "Token jorge-token" }
  end

  test "GET /api/boards lists only public boards" do
    get "/api/boards"
    assert_response :success
    slugs = JSON.parse(response.body).map { |b| b["slug"] }
    assert_includes slugs, "feature-requests"
    assert_not_includes slugs, "internal"
  end

  test "POST /api/posts requires authentication" do
    post "/api/posts", params: { post: { board_id: boards(:requests).id, title: "Nope" } }
    assert_response :unauthorized
  end

  test "POST /api/posts creates a post attributed to the current user" do
    assert_difference "Post.count", 1 do
      post "/api/posts", params: { post: { board_id: boards(:requests).id, title: "New idea" } }, headers: auth
    end
    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "open", body["status"]
    assert_equal "jorge@example.com", body["author"]
  end

  test "POST /api/posts/:id/vote toggles the current user's vote" do
    target = posts(:csv_export)

    post "/api/posts/#{target.id}/vote", headers: auth
    assert_response :success
    body = JSON.parse(response.body)
    assert body["voted"]
    assert_equal 1, body["vote_count"]

    post "/api/posts/#{target.id}/vote", headers: auth
    body = JSON.parse(response.body)
    assert_not body["voted"]
    assert_equal 0, body["vote_count"]
  end

  test "unknown post returns 404" do
    get "/api/posts/999999"
    assert_response :not_found
  end

  test "GET /api/comments filters by post" do
    get "/api/comments", params: { post: posts(:dark_mode).id }
    assert_response :success
    bodies = JSON.parse(response.body).map { |c| c["body"] }
    assert_equal [ "I would love this.", "Same here, +1." ], bodies
  end

  test "POST /api/comments adds a comment and bumps comment_count" do
    target = posts(:csv_export)
    assert_difference -> { target.comments.count }, 1 do
      post "/api/comments", params: { comment: { post_id: target.id, body: "Please!" } }, headers: auth
    end
    assert_response :created
    assert_equal "jorge@example.com", JSON.parse(response.body)["author"]

    get "/api/posts/#{target.id}"
    assert_equal 1, JSON.parse(response.body)["comment_count"]
  end
end
