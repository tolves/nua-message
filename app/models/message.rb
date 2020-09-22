class Message < ApplicationRecord
  paginates_per 5
  belongs_to :inbox
  belongs_to :outbox
  scope :unread, -> { where(read: false) }

  def self.last_message(message_id)
    @message = Message.find(message_id)
  end

  def self.get_user_messages(last_message)
    Message.where('(inbox_id = ? AND outbox_id = ?) OR (outbox_id = ? AND inbox_id = ?)', last_message.inbox_id, last_message.outbox_id, last_message.inbox_id, last_message.outbox_id).order(Created_at: :desc)
  end
end