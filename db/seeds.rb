# Demo data for Pulse. Idempotent: re-running does not create duplicates.
# Run with: bin/rails db:seed

demo = User.find_or_create_by!(email: "demo@pulse.dev") do |u|
  u.password = "demo12345"
end
alice = User.find_or_create_by!(email: "alice@pulse.dev") do |u|
  u.password = "demo12345"
end

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
    p.author = demo
  end

  # A couple of demo votes so vote_count is non-zero.
  [ demo, alice ].first(rand(0..2)).each do |voter|
    post.votes.find_or_create_by!(user: voter)
  end
end

# A short comment thread on the first post.
dark_mode = Post.find_by(title: "Dark mode")
if dark_mode
  [ [ demo, "Yes please, my eyes!" ], [ alice, "Would use this daily." ] ].each do |author, body|
    dark_mode.comments.find_or_create_by!(body: body) { |c| c.author = author }
  end
end

puts "Seeded #{User.count} users, #{Board.count} board, #{Post.count} posts, " \
     "#{Vote.count} votes, #{Comment.count} comments."
