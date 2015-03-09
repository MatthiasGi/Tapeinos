# This controller handles non-administrative tasks that allow every user to
#    create their own account and also edit/delete it.

class UsersController < ApplicationController

  # Only servers without user-account are allowed to create an account, only
  #    servers with an user-account are allowed to edit/delete it.
  before_action :require_server, :no_user, only: [ :new, :create ]
  before_action :require_user, only: [ :edit, :update, :destroy ]

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

  # Show a settings page to the user allowing him to edit various settings and
  #    delete his account.
  def edit; end

  # Save all changes regarding the user itself but also the nested servers.
  def update
    user_params = params.require(:user).permit(
      :email, :password, :password_confirmation,
      servers_attributes: [ :id, :size_talar, :size_rochet ])
    flash.now[:changes_saved] = @current_user.update(user_params)
    render :edit
  end

  # Delete the user, if the server really wishes to. Ignorant.
  def destroy

    # Gather all linked servers and generate new seeds (security and such).
    servers = @current_user.servers
    @current_user.destroy
    servers.map(&:generate_seed)

    # Inform the former user and provide him with a new login-method
    UserMailer.user_deleted_mail(servers.first).deliver_later
    flash.now[:user_deleted] = true
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
