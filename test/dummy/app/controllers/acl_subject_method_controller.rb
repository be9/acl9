class AclSubjectMethodController < ApplicationController
  access_control :subject_method => :the_only_user do
    allow :the_only_one
  end

  def index
    head :ok
  end

  private

  alias_method :the_only_user, :current_user
  def current_user
    raise "ACK!"
  end
end
