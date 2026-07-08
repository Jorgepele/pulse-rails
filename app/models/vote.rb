# An upvote on a post. Port of the Django `Vote` model: a vote belongs to a
# user, one per (post, user), enforced in the DB and here.
class Vote < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :user_id, uniqueness: { scope: :post_id }
end
