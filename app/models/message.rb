class Message < ApplicationRecord
  paginates_per 5
  belongs_to :inbox
  belongs_to :outbox

  def self.unread_count(user)
    count = user.inbox.messages.where('read = ?', false).group(:outbox_id).count
    sum = 0
    count.each_value do |f|
      sum = sum +f
    end
    count[:sum] = sum
    return count
  end

  def self.get_messages(user)
    messages = user.inbox.messages.order(created_at: :desc).group(:outbox_id).from(Message.order(created_at: :desc), :messages)
  end

  def self.last_message(user_id)
    message = Message.find(user_id)
  end

  def self.messages_read(last_message)
    Message.where('inbox_id = ? AND outbox_id = ?', last_message.inbox_id, last_message.outbox_id).update(read: true)
  end

  def self.get_user_messages(last_message)
    Message.where('(inbox_id = ? AND outbox_id = ?) OR (outbox_id = ? AND inbox_id = ?)', last_message.inbox_id, last_message.outbox_id, last_message.inbox_id, last_message.outbox_id).order(Created_at: :desc)
  end

  def self.send_message (message, from, to)
    message = Message.new(body: message, outbox: from.outbox, inbox: to.inbox)
    message.save!
  end
end