require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "generates a slug from the name on create" do
    org = Organization.create!(name: "New Co", owner: users(:jorge))
    assert_equal "new-co", org.slug
  end

  test "knows its members through memberships" do
    assert_includes organizations(:acme).members, users(:jorge)
  end
end
