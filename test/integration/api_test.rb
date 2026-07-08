require "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  test "GET /api/boards lists only public boards" do
    get "/api/boards"
    assert_response :success
    slugs = JSON.parse(response.body).map { |b| b["slug"] }
    assert_includes slugs, "feature-requests"
    assert_not_includes slugs, "internal"
  end

  test "POST /api/posts creates a post" do
    assert_difference "Post.count", 1 do
      post "/api/posts", params: { post: { board_id: boards(:requests).id, title: "New idea" } }
    end
    assert_response :created
    assert_equal "open", JSON.parse(response.body)["status"]
  end

  test "POST /api/posts/:id/vote toggles the vote" do
    target = posts(:csv_export)

    post "/api/posts/#{target.id}/vote", params: { voter_token: "tester" }
    assert_response :success
    body = JSON.parse(response.body)
    assert body["voted"]
    assert_equal 1, body["vote_count"]

    post "/api/posts/#{target.id}/vote", params: { voter_token: "tester" }
    body = JSON.parse(response.body)
    assert_not body["voted"]
    assert_equal 0, body["vote_count"]
  end

  test "unknown post returns 404" do
    get "/api/posts/999999"
    assert_response :not_found
  end
end
