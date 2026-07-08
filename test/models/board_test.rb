require "test_helper"

class BoardTest < ActiveSupport::TestCase
  test "generates a slug from the name on create" do
    board = organizations(:acme).boards.create!(name: "New Ideas")
    assert_equal "new-ideas", board.slug
  end

  test "keeps an explicit slug" do
    board = organizations(:acme).boards.create!(name: "New Ideas", slug: "custom")
    assert_equal "custom", board.slug
  end

  test "requires a name" do
    assert_not organizations(:acme).boards.new.valid?
  end
end
