require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "a user cannot join the same organization twice" do
    dup = Membership.new(user: users(:jorge), organization: organizations(:acme), role: "member")
    assert_not dup.valid?
  end

  test "rejects an unknown role" do
    m = Membership.new(user: users(:alice), organization: organizations(:acme), role: "boss")
    assert_not m.valid?
  end
end
