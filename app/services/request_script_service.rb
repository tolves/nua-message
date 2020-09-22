class RequestScriptService
  def initialize(patient, doctor, admin)
    @patient = patient
    @doctor = doctor
    @admin = admin
  end

  def call
    request_payment
  rescue StandardError => e
    send_message_to_admin
    OpenStruct.new({success?: false, error: e})
  else
    request_script
    OpenStruct.new({success?: true, result: result})
  ensure
    save_payment
  end

  private

  def request_payment
    PaymentProviderFactory.provider.debit_card(@patient)
  end

  def send_message_to_admin
    SendMessageService.new("#{@patient.full_name} payment failed", from: @patient.outbox.id, to: @admin.inbox.id).call
  end

  def request_script
    SendMessageService.new("#{@patient.full_name} request a new script", from: @patient.outbox.id, to: @doctor.inbox.id).call
  end

  def save_payment
    @patient.payments.create
  end

end