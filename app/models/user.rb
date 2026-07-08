# An account. Uses has_secure_password (bcrypt) for the password, and a
# random API token sent on each request as `Authorization: Token <token>`,
# mirroring the DRF token auth in the Django version.
class User < ApplicationRecord
  has_secure_password

  has_many :owned_organizations, class_name: "Organization", foreign_key: :owner_id, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :normalize_email
  has_secure_token  # fills :token on create and adds #regenerate_token

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
