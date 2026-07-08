# A collection of feature requests. Port of the Django `Board` model.
class Board < ApplicationRecord
  has_many :posts, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Fill the slug from the name before validation, like Django's save() override.
  before_validation :set_slug, on: :create

  private

  def set_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end
end
