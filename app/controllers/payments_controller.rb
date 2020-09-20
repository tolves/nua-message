class PaymentsController < ApplicationController
  def index
  end

  def show
    @payment = Payment.new
  end

  def create
    @patient = User.current
    @doctor = User.default_doctor
    @admin = User.default_admin

    # send a message to the doctor if payment successful
    # # when an error catched:
    # 1. dont send message to the doctor
    # 2. send an error message to admin
    # 3. alert patient payment unsuccessful
    # 4. log the error message

    message = @patient.full_name + " requested a new script."

    begin
      Payment.request_payment
      Message.send_message(message, @patient, @doctor)
      flash[:info] = 'Payment Successful'
    rescue StandardError => e
      message += ' But failed when payment, check the logs please.'
      Message.send_message(message, @patient, @admin)
      flash[:danger] = 'Payment Failed. Please contact the administrator'
      logger.debug e.message
    ensure
      Payment.save_payment_record(payment_params)
      flash[:warning] = 'Payment record has created'
    end

    redirect_to messages_url
  end

  private

  def payment_params
    params.require(:payment).permit(:user_id)
  end
end
