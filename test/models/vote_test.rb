require "test_helper"

class VoteTest < ActiveSupport::TestCase
  test "the same voter cannot vote twice on a post" do
    post = posts(:csv_export)
    post.votes.create!(voter_token: "abc")
    duplicate = post.votes.build(voter_token: "abc")
    assert_not duplicate.valid?
  end

  test "the same token may vote on different posts" do
    posts(:dark_mode).votes.create!(voter_token: "shared")
    other = posts(:csv_export).votes.build(voter_token: "shared")
    assert other.valid?
  end
end
