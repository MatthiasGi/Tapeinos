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

  def edit
    @user = User.find_by(password_reset_token: params[:token])

    if @user.nil?
      flash.now[:invalid_token] = true
      render :new
    elsif @user.password_reset_expired?
      flash.now[:expired_token] = true
      render :new
    end
  end

  def update
  end

end
