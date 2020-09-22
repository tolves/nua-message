class SendMessageService
  def initialize(body, from: nil, to: nil)
    @body = body
    @from = from
    @to = to
  end

  def call
    result = Message.create(body: @body, outbox_id: @from, inbox_id: @to)
  rescue StandardError => e
    OpenStruct.new({success?: false, error: e})
  else
    OpenStruct.new({success?: true, result: result})
  end

  private

  #attr_reader :body, :from, :to
end