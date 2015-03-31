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
    @user.update(user_params) and return redirect_to admin_users_path
    render :edit
  end

  # Delete a user.
  def destroy
    @user.destroy
    redirect_to admin_users_path
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
      :role)
  end

end
