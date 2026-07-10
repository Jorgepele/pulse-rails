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

  # Counts used by the JSON serializers. `size` reuses the association when it has
  # already been loaded (see the `includes` in the controllers) and only falls back
  # to a COUNT query otherwise — `count` would always hit the database, once per
  # post, which is the N+1 problem.
  def vote_count
    votes.size
  end

  def comment_count
    comments.size
  end
end
