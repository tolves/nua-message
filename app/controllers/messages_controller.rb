class MessagesController < ApplicationController
  def index
    patient = User.current
    doctor = User.default_admin
    admin = User.default_doctor

    @out = {:messages => patient.get_messages.page(params[:page]), :fullname => patient.full_name, :unread => patient.unread},
        {:messages => doctor.get_messages.page(params[:page]), :fullname => doctor.full_name, :unread => doctor.unread},
        {:messages => admin.get_messages.page(params[:page]), :fullname => admin.full_name, :unread => admin.unread}

    respond_to do |format|
      format.json { render json: @out }
      format.html { render :index }
    end
  end

  def show
    last_message = Message.last_message (params[:id])
    MarkAsReadService.new(last_message).call
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
    message = SendMessageService.new(message_params[:body], from: message_params[:outbox], to: message_params[:inbox]).call
    if message && message.success?
      flash[:success] = 'The message was successfully sent to the recipient'
      redirect_to action: :index
    else
      flash[:warning] = message.error
      render :new
    end
  end

  def destroy
  end

  private

  def message_params
    params.require(:message).permit(:body, :inbox, :outbox)
  end
end
