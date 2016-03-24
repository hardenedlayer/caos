class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :login_required, except: [:new, :create]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def update_password
    # http://stackoverflow.com/a/88341/1111002
    @user.password = [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
    @user.password_at = Time.now
    NotificationMailer.otp_notification(@user).deliver_now
    debug "PASSWORD -------------------------- #{@user.password}"
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.find_by(mail: user_params[:mail])
    if @user
      update_password
      @user.save
      session[:user_id] = @user.id
      return redirect_to @user
    end

    @user = User.new(user_params)
    @user.perms = ':guest:'
    @user.name = @user.mail.split('@').first
    update_password

    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      ### just for current_user
      begin
        @user = User.find(session[:user_id])
        return if @user

        @user = User.find(params[:id])
      rescue
        session.clear
        flash[:error] = 'i18n.auth.login_required'
        return redirect_to new_user_url
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:mail, :name, :comment, :password, :password_confirmation, :password_at, :perms)
    end
end
