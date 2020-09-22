class MarkAsReadService
  def initialize(message)
    @message = message
  end

  def call
    Message.unread.where('inbox_id = ? AND outbox_id = ?', @message.inbox_id, @message.outbox_id).update(read: true)
  end

  private

end