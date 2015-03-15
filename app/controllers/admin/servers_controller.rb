# The administrative interface for managing servers

class Admin::ServersController < Admin::AdminController

  # The mentioned actions require a server to be present via parameters, which
  #    ensured by this action.
  before_action :get_server, only: [ :edit, :update, :destroy ]

  # ============================================================================

  # Offers a form to create a new server.
  def new
    @server = Server.new
  end

  # Actually creates the server.
  def create
    @server = Server.new(server_params)
    @server.save and redirect_to admin_servers_path or render :new
  end

  # Lists all available servers.
  def index
    @servers = Server.all.order(:lastname)
  end

  # Edit every saved attribute for a server.
  def edit; end

  # Validate and save the updated attributes.
  def update
    @server.update(server_params) and return redirect_to admin_servers_path
    render :edit
  end

  # Destroys the selected server by removing him from the database.
  def destroy
    @server.destroy
    redirect_to admin_servers_path
  end

  # ============================================================================

  private

  # Gets the server specificied by the parameters. If no server is found, list
  #    all available servers.
  def get_server
    @server = Server.find_by(id: params[:id]) or redirect_to admin_servers_path
  end

  # Ensures that only valid parameters are permitted (strong-parameters).
  def server_params
    params.require(:server).permit(:firstname, :lastname, :email, :birthday,
      :sex, :size_talar, :size_rochet, :since, :rank, :user_id)
  end

end
