class PlansController < ApplicationController

  # Only servers are allowed to register for the plans
  before_action :require_server

  # ============================================================================

  # Displays all plans available to the server, filters out old ones.
  def index
    @plans = Plan.all.find_all{ |p| !p.last_date.past? rescue false } \
      .sort_by(&:first_date)
  end

end
