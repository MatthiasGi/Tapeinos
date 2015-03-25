# This controller handles the initial setup for the software.

class SetupController < ApplicationController
  include Wicked::Wizard

  # The setup has its own layout, which includes a nifty progressbar.
  layout 'layouts/setup'

  # Destroy all session-data before running the setup.
  before_action :logout, :destroy_currents

  # Only run the setup, if no user is found.
  before_action :check_necessity

  # The current and available steps are calculated.
  before_action :current_step

  # This controller is the ONLY one, that should not be skipped, if a setup is
  #    needed. For obvious reasons.
  skip_before_action :require_setup

  # Tell the wizard-gem what steps are necessary to rule the world.
  steps :authenticate, :domain, :mailer, :server, :finish

  # ============================================================================

  # Shows the currently available step to the user.
  def show

    # The first step authenticates the user as server-administrator. All
    #    following steps should only be allowed, if the user has already
    #    authenticated to prevent any external harm.
    if step == :authenticate
      token = SecureRandom.base64(32)
      File.write('SETUP_CODE', token)
    else
      session[:authenticated] or return redirect_to wizard_path(:authenticate)
    end

    # Differ the current step to load the current settings for display.
    case step
    when :domain
      @domain = SettingsHelper.get(:domain, request.base_url)
      @redis = SettingsHelper.get(:redis, 'redis://localhost:6379')
    when :mailer
      @server = SettingsHelper.get(:email_server, 'smtp.gmail.com')
      @port = SettingsHelper.get(:email_port, 587)
      @username = SettingsHelper.get(:email_username)
      @password = SettingsHelper.get(:email_password)
      @email = SettingsHelper.get(:email_email)
      @name = SettingsHelper.get(:email_name)
    when :server
      @server = Server.new
    when :finish
      # Something went wrong: Nobody should be here.
      return redirect_to root_path
    end

    # Finally let wicked decide what to render.
    render_wizard
  end

  # If data is inserted, it will end up here.
  def update

    # Decide step by step what should be done with the data.
    case step

    when :authenticate
      # This step checks, if the user has access to the file_system and thus is
      #    most likely an authenticated server-administrator setting up the app.
      if File.exists?('SETUP_CODE') and
          params[:token] == File.read('SETUP_CODE')
        session[:authenticated] = true
        redirect_to next_wizard_path
        File.delete('SETUP_CODE')
      else
        flash.now[:invalid_token] = true
        render_wizard
      end

    when :domain
      config = params.require(:settings).permit(:domain, :redis)
      SettingsHelper.set(:domain, config[:domain])
      SettingsHelper.set(:redis, config[:redis])
      redirect_to next_wizard_path

    when :mailer
      config = params.require(:settings).permit(:server, :port, :username,
        :password, :email, :name)
      SettingsHelper.set(:email_server, config[:server])
      SettingsHelper.set(:email_port, config[:port])
      SettingsHelper.set(:email_username, config[:username])
      SettingsHelper.set(:email_password, config[:password])
      SettingsHelper.set(:email_email, config[:email])
      SettingsHelper.set(:email_name, config[:name])
      redirect_to next_wizard_path

    when :server
      # The last data is inserted: generate a server
      server_params = params.require(:server).permit(:firstname, :lastname,
        :email, :sex)
      @server = Server.new(server_params)
      @server.save or return render_wizard

      # Create a password and an assigned administrative user
      @password = SecureRandom.base64(12)
      user = User.new({ email: @server.email, password: @password, admin: true })
      @server.update(user: user)

      # Render the last template but also update the steps.
      @current_step = @current_steps
      @current_percentage = 100
      render :finish

    end
  end

  # ============================================================================

  private

  # Check, if the setup is really necessary. Could be, that the path was called
  #    accidentally.
  def check_necessity
    User.any? and redirect_to root_path
  end

  # Calculate the currently active step, all available steps and the percentage.
  def current_step
    @current_step = wizard_steps.index(step) + 1
    @current_steps = wizard_steps.count
    @current_percentage = @current_step * 100 / @current_steps
  end

end
