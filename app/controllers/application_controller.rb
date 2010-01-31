class ApplicationController < ActionController::Base
  include HoptoadNotifier::Catcher  
  
  protect_from_forgery
  filter_parameter_logging :password, :password_confirmation

  helper_method :current_user, :signed_in?

  rescue_from ActiveRecord::RecordNotFound, :with => :not_found
  rescue_from CanCan::AccessDenied, :with => :access_denied

  # FIXME - remove it for final release
  before_filter :beta
protected

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def current_user
    @current_user ||= current_user_session && current_user_session.user
  end

  def signed_in?
    current_user ? true : false
  end

private
  # FIXME - remove it for final release
  def beta
    authenticate_or_request_with_http_basic do |username, password|
      username == "beta" && password == YAML.load_file(File.join(RAILS_ROOT, 'tmp', 'pass.yml'))["password"]
    end
  end

  def access_denied
    render 'static/access_denied', :status => 401
  end

  def not_found
    render 'static/not_found', :status => 404
  end
end
