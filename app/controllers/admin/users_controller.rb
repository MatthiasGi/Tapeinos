# Administrative user-managment is done here.

class Admin::UsersController < Admin::AdminController

  # Managing users is only available to superadministrators.
  before_action :require_root

  # Ensures that actions, that need a user provided by parameters get a user
  #    provided by parameters.
  before_action :get_user, only: [ :edit, :update, :destroy ]

  # ============================================================================

  # Lists all available users for the administrator.
  def index
    @users = User.all
  end

  # Shows a form for editing users.
  def edit; end

  # Actually saving changes done to the user.
  def update
    @user.update(user_params) or return render :edit
    update_session(@user)
    redirect_to admin_users_path
  end

  # Delete a user.
  def destroy
    # Last root can't be deleted
    if @user.root? and User.where(role: :root).count == 1
      flash.now[:cant_delete_last_root] = true
      return render :edit
    end

    # All other users will be deleted.
    @user.destroy
    redirect_to @current_user == @user ? logout_path : admin_users_path
  end

  # ============================================================================

  private

  # Fetches the user selected by the parameters or aborts, if noone was found.
  def get_user
    @user = User.find_by(id: params[:id]) or redirect_to admin_users_path
  end

  # Strong-parameters ftw.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation,
      :role, server_ids: [])
  end

end
