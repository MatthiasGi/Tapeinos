# This controller handles the initial setup for the software.

class SetupController < ApplicationController

  # The setup-controller provides a wizard-like overview to not overwhelm the
  #    user with to many options at once.
  include Wicked::Wizard

  # The user is able to setup all general settings, thus this controller is able
  #    to modify them and is provided with the default methods.
  include AdjustsSettings

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
    # If not authenticating/-ed: block all further action.
    step == :authenticate or session[:authenticated] or
      return redirect_to wizard_path(:authenticate)

    # Differ the current step to load the current settings for display.
    case step

      # The first step authenticates the server-root-user. Generate a token that
      #    he can read from the file-system.
      when :authenticate
        File.write('SETUP_CODE', SecureRandom.base64(32))

      # Domain- and mailer-steps alter global server configuration via the
      #    SettingsHelper. They are provided with current settings.
      when :domain, :mailer
        get_settings

        # If no setting is set, provide the user with default settings.
        defaults = {
          domain: request.base_url,
          redis: 'redis://localhost:6379',
          timezone: 'UTC',
          email_server: 'smtp.gmail.com',
          email_port: 587
        }
        defaults.each { |k, v| @settings[k] ||= v }

      # Here a new server is generated. Create an empty one to not let the form
      #    screw up.
      when :server
        @server = Server.new

      # Something went wrong: Nobody should be here.
      when :finish
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
        File.delete('SETUP_CODE')
        redirect_to next_wizard_path
      else
        flash.now[:invalid_token] = true
        render_wizard
      end

    # The user provided global settings. Save them.
    when :domain, :mailer
      save_settings
      redirect_to next_wizard_path

    # The last data is inserted: generate a server
    when :server
      server_params = params.require(:server).permit(:firstname, :lastname,
        :email, :sex)
      @server = Server.new(server_params)
      @server.save or return render_wizard

      # Create a password and an assigned administrative user
      @password = SecureRandom.base64(12)
      user = User.new(email: @server.email, password: @password, role: :root)
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
