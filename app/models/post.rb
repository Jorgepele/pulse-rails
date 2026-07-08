# A single feature request on a board. Port of the Django `Post` model.
class Post < ApplicationRecord
  STATUSES = %w[open planned in_progress done declined].freeze

  belongs_to :board
  belongs_to :author, class_name: "User", optional: true
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  default_scope { order(created_at: :desc) }

  # Number of upvotes, mirroring Django's `vote_count` property.
  def vote_count
    votes.count
  end
end
