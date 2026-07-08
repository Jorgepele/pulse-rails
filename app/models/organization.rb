# A tenant. Every board (and its posts) belongs to one organization.
# Port of the Django `Organization` model.
class Organization < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :boards, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :set_slug, on: :create

  private

  def set_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end
end
