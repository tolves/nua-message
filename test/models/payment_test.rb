require 'test_helper'

class PaymentTest < ActionDispatch::IntegrationTest
  setup do
    @patient = User.current
    @doctor = User.find_by_id(2)
    @admin = User.find_by_id(3)
  end

  test "payment message send to admin" do
    before_payment_message = @admin.inbox.messages.last
    post payments_url, params: { :payment => {user_id: User.current.id} }
    after_payment_message = @admin.inbox.messages.last
    assert_not_equal(before_payment_message, after_payment_message)
  end

  test "should Payment API is called" do
    before_doctor_message = @doctor.inbox.messages.last
    before_admin_message = @admin.inbox.messages.last
    post payments_url, params: { :payment => {user_id: User.current.id} }
    after_doctor_message = @doctor.inbox.messages.last
    after_admin_message = @admin.inbox.messages.last
    assert_equal(before_doctor_message, after_doctor_message)
    assert_not_equal(before_admin_message, after_admin_message)
  end

  test "should Payment Record is created" do
    before_payment = Payment.last.id
    post payments_url, params: { :payment => {user_id: User.current.id} }
    after_payment = Payment.last.id
    assert_equal(before_payment+1, after_payment)
  end

end