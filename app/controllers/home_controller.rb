class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @storage_usage = current_user.storage_usage
  end
end
