# The administrative interface for managing servers

class Admin::ServersController < Admin::AdminController

  def index
    @servers = Server.all.order(:lastname)
  end

end
