class MessagesController < ApplicationController
  def index
    patient = User.current
    doctor = User.default_admin
    admin = User.default_doctor

    patient_messages = Message.get_messages(patient).page params[:page]
    doctor_messages = Message.get_messages(doctor).page params[:page]
    admin_messages = Message.get_messages(admin).page params[:page]

    patient_unread_count = Message.unread_count(patient)
    doctor_unread_count = Message.unread_count(doctor)
    admin_unread_count = Message.unread_count(admin)

    @out = {:messages => patient_messages, :fullname => patient.full_name, :unread => patient_unread_count}, {:messages => doctor_messages, :fullname => doctor.full_name, :unread => doctor_unread_count}, {:messages => admin_messages, :fullname => admin.full_name, :unread => admin_unread_count}
    puts @out.inspect

    respond_to do |format|
      format.json { render json: @out }
      format.html { render :index }
    end
  end

  def show
    last_message = Message.last_message (params[:id])
    Message.messages_read(last_message)
    messages = Message.get_user_messages(last_message).page params[:page]
    @out = {:messages => messages, :last_message => last_message}

    respond_to do |format|
      format.json { render json: @out }
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
    #@message = Message.find(params[:id])
    #@message.destroy
    #flash[:success] = 'Message deleted.'
    #redirect_to action: :index
  end

  private
  def message_params
    params.require(:message).permit(:body, :inbox_id, :outbox_id)
  end
end
