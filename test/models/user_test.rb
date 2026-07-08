require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "gets a token on create" do
    user = User.create!(email: "new@example.com", password: "secret123")
    assert user.token.present?
  end

  test "normalizes the email" do
    user = User.create!(email: "  MixedCase@Example.com ", password: "secret123")
    assert_equal "mixedcase@example.com", user.email
  end

  test "authenticates with the right password" do
    assert users(:jorge).authenticate("secret123")
    assert_not users(:jorge).authenticate("wrong")
  end

  test "rejects a duplicate email" do
    dup = User.new(email: "jorge@example.com", password: "secret123")
    assert_not dup.valid?
  end
end
