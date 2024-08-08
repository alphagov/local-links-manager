class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  include ServicePermissions

  helper_method :gds_editor?

  before_action :authenticate_user!
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
