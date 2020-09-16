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
end