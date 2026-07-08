require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "requires a body" do
    assert_not posts(:dark_mode).comments.build.valid?
  end

  test "orders comments oldest first" do
    bodies = posts(:dark_mode).comments.map(&:body)
    assert_equal [ "I would love this.", "Same here, +1." ], bodies
  end
end
