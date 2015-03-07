class ForgotPasswordsController < ApplicationController

  def new; end

  def create
    email = params[:user][:email]
    @user = User.find_by(email: email)

    if @user.nil?
      @user = User.new(email: email)
      @user.errors.add(:email, t('.email_not_found'))
    elsif @user.password_reset_expired?
      @user.prepare_password_reset
      UserMailer.forgot_password_mail(@user).deliver_later
      flash.now[:mail_sent] = true
      @user = nil
    else
      flash.now[:reset_link_already_sent] = true
    end

    render :new
  end

end
