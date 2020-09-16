class PaymentsController < ApplicationController
  def index
  end

  def show
    @payment = Payment.new
  end

  def create
    @patient = User.current
    @doctor = User.find_by_id(2)
    @admin = User.find_by_id(3)

    # send a message to the doctor if payment successful
    # # when an error catched:
    # 1. dont send message to the doctor
    # 2. send an error message to admin
    # 3. alert patient payment unsuccessful
    # 4. log the error message
    begin
      @payment_result = PaymentProviderFactory.provider.debit_card(@patient)
      message = @patient.first_name + ' ' + @patient.last_name + " request a new script."
      Message.create(body: message, outbox: @patient.outbox, inbox: @doctor.inbox)
    rescue StandardError => e
      message = @patient.first_name + ' ' + @patient.last_name + " request a new script. But failed when payment, check the logs please."
      Message.create(body: message, outbox: @patient.outbox, inbox: @admin.inbox)
      flash[:warning] = 'Payment Failed. Please contact the administrator'
      logger.debug e.message
    ensure
      @payment = Payment.new(payment_params)
      @payment.save
      flash[:info] = 'Payment record has created'
    end

    redirect_to messages_url
  end

  private

  def payment_params
    params.require(:payment).permit(:user_id)
  end

end