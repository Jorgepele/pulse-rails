require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "defaults to open status" do
    post = boards(:requests).posts.create!(title: "Anything")
    assert_equal "open", post.status
  end

  test "rejects an unknown status" do
    post = boards(:requests).posts.build(title: "X", status: "bogus")
    assert_not post.valid?
  end

  test "vote_count reflects the number of votes" do
    post = posts(:dark_mode)
    assert_equal 1, post.vote_count
    post.votes.create!(user: users(:alice))
    assert_equal 2, post.vote_count
  end
end
