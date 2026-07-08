require "test_helper"

class VoteTest < ActiveSupport::TestCase
  # Fixture: jorge already has a vote on the dark_mode post.
  test "the same user cannot vote twice on a post" do
    duplicate = posts(:dark_mode).votes.build(user: users(:jorge))
    assert_not duplicate.valid?
  end

  test "the same user may vote on a different post" do
    other = posts(:csv_export).votes.build(user: users(:jorge))
    assert other.valid?
  end
end
