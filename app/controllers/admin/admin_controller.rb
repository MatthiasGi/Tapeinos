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

  # This function checks, whether the currently logged in user is an
  #    administrator and makes sure that only then he is able to access.
  def require_admin
    @admin = @current_user.administrator? or redirect_to root_path
  end

  # If an administrator is not enough, this function checks, whether the user is
  #    a superadministrator (root).
  def require_root
    @current_user.root? or redirect_to admin_servers_path
  end

end
