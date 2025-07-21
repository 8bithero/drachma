class User < ApplicationRecord
  has_secure_password

  has_many :statements, dependent: :destroy
  has_many :line_items, through: :statements

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "is invalid" },
            uniqueness: { case_sensitive: false }

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }

  validates :password,
            length: { minimum: 8 },
            if: -> { password.present? }

  validates :refresh_token,
            length: { is: 64 },
            allow_blank: true,
            uniqueness: true,
            format: { with: /\A[a-f0-9]+\z/, message: "must be hexadecimal" }

  validates :refresh_token_expires_at,
            presence: true,
            if: :refresh_token?

  validate :refresh_token_expires_at_must_be_future,
            if: :refresh_token_expires_at_changed?

  private

  def refresh_token_expires_at_must_be_future
    if refresh_token_expires_at.present? && refresh_token_expires_at <= Time.current
      errors.add(:refresh_token_expires_at, "must be in the future")
    end
  end
end
