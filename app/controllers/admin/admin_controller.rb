# This controller should be extended by every controller which manages
#    administrative tasks.

class Admin::AdminController < ApplicationController

  # All controllers in this directroy (descendants of this controller) should
  #    only be invoked by real administrative users.
  before_action :require_user, :require_admin

  # The administration uses another layout with sidebar for navigation.
  layout 'administration'

  # ============================================================================

  private

  # This function checks, whether the currently logged in user is also an
  #    administrator and makes sure that only then he is able to access.
  def require_admin
    @admin = @current_user.admin or redirect_to root_path
  end

end
