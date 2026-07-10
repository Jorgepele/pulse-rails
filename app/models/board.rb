# A collection of feature requests. Port of the Django `Board` model.
class Board < ApplicationRecord
  belongs_to :organization
  has_many :posts, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: { scope: :organization_id }

  # Tenant visibility, mirroring the Django `BoardQuerySet.visible_to`: any public
  # board, plus the private boards of the organizations the user belongs to.
  scope :visible_to, ->(user) {
    return where(is_public: true) if user.nil?

    left_joins(organization: :memberships)
      .where("boards.is_public = ? OR memberships.user_id = ?", true, user.id)
      .distinct
  }

  # Fill the slug from the name before validation, like Django's save() override.
  before_validation :set_slug, on: :create

  private

  def set_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end
end
