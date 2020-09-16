class MessagesController < ApplicationController
  def index
    @patient = User.current
    @doctor = User.find_by_id(2)
    @admin = User.find_by_id(3)

    @patient_messages = @patient.inbox.messages.order(created_at: :desc).group(:inbox_id).from(Message.order(created_at: :desc), :messages).page params[:page]
    @doctor_messages = @doctor.inbox.messages.order(created_at: :desc).group(:outbox_id).from(Message.order(created_at: :desc), :messages).page params[:page]
    @admin_messages = @admin.inbox.messages.order(created_at: :desc).group(:outbox_id).from(Message.order(created_at: :desc), :messages).page params[:page]

    @patient_unread_count = Message.unread_count(@patient)
    @doctor_unread_count = Message.unread_count(@doctor)
    @admin_unread_count = Message.unread_count(@admin)

    json = [messages: [patient_message: @patient_messages, doctor_messages: @doctor_messages, admin_messages: @admin_messages], unread: [patient: @patient_unread_count, doctor: @doctor_unread_count, admin: @admin_unread_count]]
    #Message.create(body: '1. this is an message test doctor unread', outbox_id: 4, inbox_id: 2)
    respond_to do |format|
      format.json { render json: json }
      format.html { render :index }
    end
  end

  def show
    @last_message = Message.find(params[:id])
    Message.where('inbox_id = ? AND outbox_id = ?', @last_message.inbox_id, @last_message.outbox_id).update(read: true)
    @messages = Message.where('(inbox_id = ? AND outbox_id = ?) OR (outbox_id = ? AND inbox_id = ?)', @last_message.inbox_id, @last_message.outbox_id, @last_message.inbox_id, @last_message.outbox_id).order(Created_at: :desc).page params[:page]

    json = @messages
    respond_to do |format|
      format.json { render json: json }
      format.html { render :show }
    end
  end

  def new
    @message = Message.new
  end

  def create
    begin
      @message = Message.new(message_params)
      @message.save
      flash[:success] = 'Message sent successful.'
    rescue StandardError => e
      flash[:warning] = 'Message sent failed.'
      logger.debug e.message
    end

    redirect_to action: :index
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    flash[:success] = 'Message deleted.'
    redirect_to action: :index
  end

  private
  def message_params
    params.require(:message).permit(:body, :inbox_id, :outbox_id)
  end
end
