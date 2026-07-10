require "test_helper"

# Listing posts must cost the same number of queries whatever the page holds.
# Guards against the N+1 problem: before the `includes`, every post triggered
# its own COUNT queries for votes and comments, plus one for its author.
class QueryCountTest < ActionDispatch::IntegrationTest
  test "listing posts does not scale with the number of posts" do
    assert_equal queries_listing_posts(1), queries_listing_posts(5)
  end

  private

  def queries_listing_posts(count)
    Comment.delete_all
    Vote.delete_all
    Post.delete_all
    board = boards(:requests)
    count.times do |n|
      post = board.posts.create!(title: "Post #{n}", author: users(:jorge))
      post.votes.create!(user: users(:jorge))
      post.comments.create!(author: users(:jorge), body: "A comment")
    end

    count_queries { get "/api/posts" }
  end

  # Counts the SELECTs issued while the block runs (ignoring transaction noise).
  def count_queries
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, payload|
      queries += 1 unless payload[:name].in?([ "SCHEMA", "TRANSACTION" ]) || payload[:sql].start_with?("SAVEPOINT", "RELEASE")
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
