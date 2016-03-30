class SessionsController < ApplicationController
  before_action :set_session, only: [:show, :edit, :update, :destroy]
  before_action :login_required, except: [:new, :create, :logout]

  # GET /sessions
  # GET /sessions.json
  def index
    @sessions = Session.all
  end

  # GET /sessions/new
  def new
    begin
      @user = User.find(session[:user_id])
      @session = @user.sessions.new
    rescue
      return redirect_to root_path
    end
  end

  # POST /sessions
  # POST /sessions.json
  def create
    @user = User.find(session[:user_id])
    debug "#{params[:password]}"
    if @user && @user.authenticate(params[:password])
      @session = @user.sessions.new(session_params)
      @session.login_at = Time.now
    else
      debug "Oops! login failed!"
      return redirect_to new_session_path, alert: 'i18n.auth.invalid_password'
    end

    respond_to do |format|
      if @session.save
        session[:session] = @session.id
        format.html { redirect_to @user, notice: 'i18n.auth.greeting' }
        format.json { render :show, status: :created, location: @session }
      else
        format.html { render :new }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  def logout
    session[:user_id] = nil
    session[:session] = nil
    session.delete :user_id
    session.delete :session
    session.clear
    debug "session cleared: #{session.to_json}"
    redirect_to root_path, notice: 'i18n.auth.logged_out'
  end

  private
    def set_session
      @session = Session.find(params[:id])
    end

    def session_params
      params.require(:session).permit(:user_id)
    end
end
