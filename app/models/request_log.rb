class RequestLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :ip_address, presence: true
  validates :path, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :from_ip, ->(ip) { where(ip_address: ip) }
  scope :unauthenticated, -> { where(user_id: nil) }
  scope :authenticated, -> { where.not(user_id: nil) }
end
