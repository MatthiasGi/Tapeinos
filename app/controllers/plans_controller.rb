class PlansController < ApplicationController

  # Only servers are allowed to register for the plans
  before_action :require_server

  # ============================================================================

  # NOTE: Placeholder for features yet to come.
  def index; end

end
