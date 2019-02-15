class Api::CalendarsController < ApplicationController

  before_action :require_api_key

  def show
    @events = @server.events
  end

  private

  def require_api_key
    api_key = params[:api_key] or head :unauthorized
    @server = Server.find_by(api_key: api_key) or head :unauthorized
  end

end
