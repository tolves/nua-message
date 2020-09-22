require 'test_helper'

class MessageTest < ActionDispatch::IntegrationTest
  setup do
    @patient = User.current
    @doctor = User.default_admin
    @admin = User.default_doctor
    @message = Message.create(body: 'this is an message from patient to doctor', outbox_id: @patient.outbox.id, inbox_id: @doctor.inbox.id)
  end

  test "should message unread" do
    assert_equal(false, @message.read)
  end

  test "shoule message send from patient to doctor" do
    assert_equal(@doctor.inbox.id, @message.inbox_id)
    assert_equal(@patient.outbox.id, @message.outbox_id)
  end

  test "should unread number increased" do
    count = @doctor.unread
    assert_equal(3, count[@patient.id])
  end

  test "should unread number decreased after read" do
    before_visit = @doctor.unread
    get message_url(@message.id)
    assert_response :success
    after_visit = @doctor.unread
    assert_not_equal(before_visit, after_visit)
  end

end