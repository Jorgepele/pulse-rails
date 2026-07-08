# A comment on a post. Port of the Django `Comment` model.
# Author is omitted until this app has authentication (see README).
class Comment < ApplicationRecord
  belongs_to :post

  validates :body, presence: true

  default_scope { order(created_at: :asc) }
end
