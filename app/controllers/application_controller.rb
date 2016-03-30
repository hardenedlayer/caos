class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :debug_session
  before_action :login_required

  private
  def current_session
    begin
      @current_session ||= Session.find(session[:session])
    rescue
      debug "Oops! current_session: #{@current_session}"
    end
  end
  helper_method :current_session

  def debug message
    puts "\e[35m### DEBUG: #{message}\e[0m"
  end

  def set_locale
    locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    I18n.locale = locale || I18n.default_locale
    debug "locale set to '#{I18n.locale}'"
  end

  def debug_session
    debug "session: #{session.to_json}"
  end

  def login_required
    debug "session from session #{session[:session]}"
    debug "user_id from session #{session[:user_id]}"
    unless current_session
      return redirect_to new_session_path,
        notice: 'i18n.auth.login_with_one_time_password'
    end
    @current_session.logout_at = Time.now
    @current_session.save
  end

  def timing str
    @t2 = Time.now
    @t1 = @t2 if not defined? @t1
    @t0 = @t2 if not defined? @t0
    puts "### Timing: %9.6fs/%9.6fs for %s" % [(@t2 - @t0), (@t2 - @t1), str]
    @t1 = @t2
  end
end
