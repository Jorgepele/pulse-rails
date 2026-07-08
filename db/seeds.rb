# Demo data for Pulse. Idempotent: re-running does not create duplicates.
# Run with: bin/rails db:seed

board = Board.find_or_create_by!(slug: "feature-requests") do |b|
  b.name = "Feature Requests"
end

posts = [
  { title: "Dark mode", body: "Please add a dark theme.", status: "planned" },
  { title: "Slack integration", body: "Notify a channel on new posts.", status: "open" },
  { title: "CSV export", body: "Export all feedback to CSV.", status: "open" },
  { title: "Mobile app", body: "A companion app for iOS/Android.", status: "declined" }
]

posts.each do |attrs|
  post = board.posts.find_or_create_by!(title: attrs[:title]) do |p|
    p.body = attrs[:body]
    p.status = attrs[:status]
  end

  # A couple of demo votes so vote_count is non-zero.
  [ "demo-1", "demo-2" ].first(rand(0..2)).each do |token|
    post.votes.find_or_create_by!(voter_token: token)
  end
end

# A short comment thread on the first post.
dark_mode = Post.find_by(title: "Dark mode")
if dark_mode
  [ "Yes please, my eyes!", "Would use this daily." ].each do |body|
    dark_mode.comments.find_or_create_by!(body: body)
  end
end

puts "Seeded #{Board.count} board, #{Post.count} posts, " \
     "#{Vote.count} votes, #{Comment.count} comments."
