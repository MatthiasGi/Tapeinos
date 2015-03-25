# This controller displays static pages.

class PagesController < ApplicationController
  
  # The pages should only be visible to logged in users. All others should get
  #    the authentication dialog.
  before_action :require_server
  
  #=============================================================================
  
  # Displays the about page. It contains a version number and the changelog.
  def about
    log = "CHANGELOG.#{I18n.locale}.md"
    @changelog = File.exists?(log) ? log : 'CHANGELOG.md'
  end
  
end