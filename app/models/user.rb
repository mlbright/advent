class User < ApplicationRecord
  has_secure_password

  has_many :created_calendars, class_name: "Calendar", foreign_key: "creator_id", dependent: :destroy
  has_many :received_calendars, class_name: "Calendar", foreign_key: "recipient_id", dependent: :destroy
  has_many :calendar_views, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase
  end
end
