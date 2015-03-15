# Administrative plan- and event-managment.

class Admin::PlansController < Admin::AdminController

  # Ensures that a plan is selected for actions that need one.
  before_action :get_plan, only: [ :show, :edit, :update, :destroy ]

  # ============================================================================

  # Shows a form for creating new plans.
  def new
    @plan = Plan.new
  end

  # Actuall creates the new plan
  def create
    @plan = Plan.new(params.require(:plan).permit(:title))

    # First saving and then updating is needed because of a bug, that doesn't
    #    allow saving a model with nested, new created attributes.
    @plan.save
    @plan.update(plan_params) and return redirect_to admin_plan_path(@plan)
    render :new
  end

  # Lists all available plans and sorts them: first those without events, than
  #    the most recents
  def index
    parts = Plan.all.partition { |plan| plan.first_date }
    @plans = parts.last + parts.first.sort_by(&:first_date)
  end

  # Displays a single plan.
  def show; end

  # Allows editing of a single plan.
  def edit; end

  # Actually saves changes to a plan.
  def update
    @plan.update(plan_params) and return redirect_to admin_plan_path(@plan)
    render :edit
  end

  # Destroys a single, given plan.
  def destroy
    @plan.destroy
    redirect_to admin_plans_path
  end

  # ============================================================================

  private

  # Ensures that a plan is selected (and determines it) or aborts the specific
  #    action by redirecting to the overview with available plans.
  def get_plan
    @plan = Plan.find_by(id: params[:id]) or redirect_to admin_plans_path
  end

  # Strong-parameters. Again.
  def plan_params
    params.require(:plan).permit(:title, :remark,
      events_attributes: [ :id, :date, :title, :location, :_destroy, :needed ])
  end

end
