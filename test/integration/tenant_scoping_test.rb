require "test_helper"

# A private board, and everything hanging off it, must never leak outside the
# organization that owns it. `jorge` is a member of Acme; `alice` is not.
class TenantScopingTest < ActionDispatch::IntegrationTest
  def member = { "Authorization" => "Token jorge-token" }
  def outsider = { "Authorization" => "Token alice-token" }

  test "member sees the private board of their own organization" do
    get "/api/boards", headers: member
    slugs = JSON.parse(response.body).map { |b| b["slug"] }
    assert_includes slugs, "internal"
  end

  test "outsider does not see the private board" do
    get "/api/boards", headers: outsider
    slugs = JSON.parse(response.body).map { |b| b["slug"] }
    assert_not_includes slugs, "internal"
  end

  test "outsider cannot show the private board" do
    get "/api/boards/#{boards(:private_board).id}", headers: outsider
    assert_response :not_found
  end

  test "anonymous does not see posts of the private board" do
    get "/api/posts"
    titles = JSON.parse(response.body).map { |p| p["title"] }
    assert_not_includes titles, "Secret roadmap item"
  end

  test "member sees posts of the private board" do
    get "/api/posts", headers: member
    titles = JSON.parse(response.body).map { |p| p["title"] }
    assert_includes titles, "Secret roadmap item"
  end

  test "outsider cannot show a post on the private board" do
    get "/api/posts/#{posts(:secret).id}", headers: outsider
    assert_response :not_found
  end

  test "outsider cannot vote on a post of the private board" do
    post "/api/posts/#{posts(:secret).id}/vote", headers: outsider
    assert_response :not_found
  end

  test "outsider cannot create a post on the private board" do
    assert_no_difference "Post.count" do
      post "/api/posts",
           params: { post: { board_id: boards(:private_board).id, title: "Intruder" } },
           headers: outsider
    end
    assert_response :not_found
  end

  test "outsider cannot comment on a post of the private board" do
    assert_no_difference "Comment.count" do
      post "/api/comments",
           params: { comment: { post_id: posts(:secret).id, body: "Peeking" } },
           headers: outsider
    end
    assert_response :not_found
  end

  test "outsider does not see comments on the private board" do
    posts(:secret).comments.create!(author: users(:jorge), body: "Internal note")
    get "/api/comments", headers: outsider
    bodies = JSON.parse(response.body).map { |c| c["body"] }
    assert_not_includes bodies, "Internal note"
  end

  test "anyone authenticated can post on a public board" do
    assert_difference "Post.count", 1 do
      post "/api/posts",
           params: { post: { board_id: boards(:requests).id, title: "Please add dark mode" } },
           headers: outsider
    end
    assert_response :created
  end
end
