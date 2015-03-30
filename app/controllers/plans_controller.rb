class PlansController < ApplicationController

  # Only servers are allowed to register for the plans
  before_action :require_server

  # Every method that needs a fixed plan provided by an id gets it here.
  before_action :get_plan, only: [ :show, :update ]

  # ============================================================================

  # Displays all plans available to the server, filters out old ones.
  def index
    @plans = Plan.all.find_all{ |p| !p.last_date.past? rescue false } \
      .sort_by(&:first_date)
  end

  # Displays a form to the server where he can enroll for events.
  def show; end

  # Saves the new enrollement of the currently logged in server.
  def update
    params[:events] ||= []
    evts_param = params[:events].map { |id| Event.find_by(id: id) }
    evts_param = evts_param.compact
    events = @current_server.events - @plan.events + evts_param
    flash.now[:enrolled] = @current_server.update(events: events)
    @plan.servers.include?(@current_server) or
      @plan.servers.push(@current_server)
    render :show
  end

  # ============================================================================

  private

  # For every method that needs a fixed plan provided by an id: Get this plan or
  #    redirect to the overview of all plans.
  def get_plan
    @plan = Plan.find_by(id: params[:id]) or redirect_to plans_path
  end

end
