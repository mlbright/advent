class User < ApplicationRecord
  has_secure_password

  has_many :created_calendars, class_name: "Calendar", foreign_key: "creator_id", dependent: :destroy
  has_many :received_calendars, class_name: "Calendar", foreign_key: "recipient_id", dependent: :destroy
  has_many :calendar_views, dependent: :destroy
  has_many :request_logs, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save :downcase_email

  def can_be_deleted?
    received_calendars.empty?
  end

  def deletion_blocked_reason
    return nil if can_be_deleted?
    "User is the recipient of #{received_calendars.count} calendar(s) and cannot be deleted"
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
