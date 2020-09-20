class Payment < ApplicationRecord

  belongs_to :user
  def self.request_payment
    PaymentProviderFactory.provider.debit_card(@patient)
  end

  def self.save_payment_record(payment_params)
    payment = Payment.new(payment_params)
    payment.save
  end
end