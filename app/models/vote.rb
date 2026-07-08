# An upvote on a post. Port of the Django `Vote` model.
# Django ties a vote to a User; until this app has auth, we identify the
# voter with an opaque `voter_token` sent by the client. One vote per
# (post, voter_token) pair, enforced in the DB and here.
class Vote < ApplicationRecord
  belongs_to :post

  validates :voter_token, presence: true
  validates :voter_token, uniqueness: { scope: :post_id }
end
