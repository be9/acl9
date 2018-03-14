class ApplicationController < ActionController::Base
  before_action :before_action

  attr_accessor :current_user

  def current_user
    @current_user ||= User.find params[:user_id] if params[:user_id]
  end

  def before_action
    @foo = Foo.first
  end
end
