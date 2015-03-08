# This controller handles non-administrative tasks that allow every user to
#    create their own account and also edit/delete it.

class UsersController < ApplicationController

  # Only servers without user-account are allowed to create an account.
  before_action :require_server, :no_user, only: [ :new, :create ]

  # ============================================================================

  # Displays information about accounts.
  def new; end

  # Actually creates the account.
  def create

    # Create the new user-account
    password = SecureRandom.base64(12)
    @user = User.new({ email: @current_server.email, password: password })

    # Link all associated servers to the new user.
    servers = @current_server.siblings << @current_server
    servers.each do |server|
      server.update({ user: @user })
    end

    # Notify the user by email and visual
    UserMailer.user_created_mail(@user, password).deliver_later
    flash.now[:user_created] = true
    logout
    destroy_currents
    render 'sessions/new'

  end

  # ============================================================================

  private

  # This function assures, that no user is logged in and is therefore used to
  #    determine, if a server is not yet linked to an user.
  def no_user
    @current_user or @current_server.user and redirect_to plans_path
  end

end
