class User < ApplicationRecord

  has_one :inbox
  has_one :outbox
  has_many :payments
  has_many :messages

  scope :patient, -> { where(is_patient: true) }
  scope :admin, -> { where(is_admin: true) }
  scope :doctor, -> { where(is_doctor: true) }

  def self.current
    User.patient.first
  end

  def self.default_admin
    User.admin.first
  end

  def self.default_doctor
    User.doctor.first
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def get_messages
    inbox.messages.order(created_at: :desc).group(:outbox_id).from(Message.order(created_at: :desc), :messages)
  end

  def unread
    count = inbox.messages.unread.group(:outbox_id).count
    count[:sum] = inbox.messages.unread.count
    count
  end
end