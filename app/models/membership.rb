# Links a user to an organization with a role. Port of the Django `Membership`.
class Membership < ApplicationRecord
  ROLES = %w[owner admin member].freeze

  belongs_to :user
  belongs_to :organization

  validates :role, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :organization_id }
end
