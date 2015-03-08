# This controller handles request by users, that want to reset their password.
#    This may be the case when the password is forgotten or the user was blocked
#    because of too many failed authentication-attempts.

class ForgotPasswordsController < ApplicationController

  # Allows the user to enter his email-address.
  def new; end

  # Handles the request by email-address and generates an email.
  def create
    email = params[:user][:email]
    @user = User.find_by(email: email)

    if @user.nil?

      # User was not found: Email must be invalid.
      @user = User.new(email: email)
      @user.errors.add(:email, t('.email_not_found'))

    elsif @user.password_reset_expired?

      # There is no ongoing password-resetting-process.
      @user.prepare_password_reset
      UserMailer.forgot_password_mail(@user).deliver_later
      flash.now[:mail_sent] = true
      @user = nil

    else
      flash.now[:reset_link_already_sent] = true
    end

    render :new
  end

  # Allows the user entering a new password by calling this action with a valid
  #    token.
  def edit
    filter_token(params[:token])
  end

  # Actually saves the new password, if everything evaluates as valid.
  def update
    filter_token(params[:user][:password_reset_token]) or return

    if @user.update(params.require(:user).permit(:password, :password_confirmation))
      @user.clear_password_reset
      flash.now[:password_changed] = true
      UserMailer.password_changed_mail(@user).deliver_later
      render 'sessions/new'
    else
      render :edit
    end
  end

  # ============================================================================

  private

  # Assigns the user found by the given token to @user and validates the token.
  #    If the token is invalid (not found in the database) or already expired,
  #    this function returns false, else it returns true.
  def filter_token(token)
    @user = User.find_by(password_reset_token: token)

    if @user.nil?
      flash.now[:invalid_token] = true
      render :new
    elsif @user.password_reset_expired?
      flash.now[:expired_token] = true
      render :new
    else
      return true
    end

    false
  end

end
