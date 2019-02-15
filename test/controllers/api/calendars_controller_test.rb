require 'test_helper'

class Api::CalendarsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @server = servers(:max)
    @api_key = @server.generate_api_key
  end

  test "Without valid api-key no display" do
    get api_calendars_path(api_key: 123)
    assert_response 401
  end

  test "Access with valid api-key" do
    get api_calendars_path(api_key: @api_key)
    assert_response :success
  end

end
