class PaymentsController < ApplicationController
  def index
  end

  def show
    @payment = Payment.new
  end

  def create
    patient = User.current
    doctor = User.default_doctor
    admin = User.default_admin

    result = RequestScriptService.new(patient, doctor, admin).call

    if result && result.success?
      flash[:info] = 'Payment Successful'
    else
      flash[:danger] = "#{result.error}, Payment Failed. Please contact the administrator"
    end

    redirect_to messages_url
  end

  private

  def payment_params
    params.require(:payment).permit(:user_id)
  end
end
