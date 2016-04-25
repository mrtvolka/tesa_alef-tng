class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Exceptions

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :auth_user!


  def auth_user!
    unless user_signed_in? || devise_controller?
      session[:previous_url] = request.fullpath unless request.xhr? # do not store AJAX calls
      redirect_to new_user_session_path
    end
  end

  def after_sign_in_path_for(resource)
    if current_user.role == 'teacher'
      return teaching_path
    end
    session[:previous_url] || root_path
  end

  protected

  def user_signed_in?
    local_user_signed_in? || ldap_user_signed_in?
  end

  def current_user
    current_local_user || current_ldap_user
  end

  def user_session
    local_user_session || ldap_user_session
  end

  def log_unknown(message, *params)
    params.push request.remote_ip
    AlefLoggingSystem::Logger.unknown(message, params)
  end

  def log_fatal(message, *params)
    params.push request.remote_ip
    AlefLoggingSystem::Logger.fatal(message, params)
  end

  def log_error(message, *params)
    params.push request.remote_ip
    AlefLoggingSystem::Logger.error(message, params)
  end

  def log_warn(message, *params)
    params.push request.remote_ip
    AlefLoggingSystem::Logger.warn(message, params)
  end

  def log_info(message, *params)
    params.push request.remote_ip
    AlefLoggingSystem::Logger.info(message, params)
  end

  def log_debug(message, *params)
    params.push request.remote_ip
    AlefLoggingSystem::Logger.debug(message, params)
  end

  helper_method :user_signed_in?, :current_user, :user_session
end

