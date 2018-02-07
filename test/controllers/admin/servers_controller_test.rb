require 'test_helper'

class Admin::ServersControllerTest < ActionController::TestCase

  def setup
    user = users(:admin)
    session[:user_id] = user.id
    session[:server_id] = user.servers.first.id
  end

  test "index shows" do
    get :index
    assert_response :success
    assert_template :index
    assert_equal Server.all, assigns(:servers)
  end

  test "edit invalid server" do
    get :edit, params: { id: 1 }
    assert_redirected_to admin_servers_path
  end

  test "edit valid server" do
    server = servers(:max)
    get :edit, params: { id: server.id }
    assert_response :success
    assert_template :edit
    assert_equal server, assigns(:server)
  end

  test "show email on server without user" do
    server = servers(:heinz)
    get :edit, params: { id: server.id }
    assert_select '.server_email'
  end

  test "don't show email on server with user" do
    server = servers(:max)
    get :edit, params: { id: server.id }
    assert_select '.server_email', false
  end

  test "update with wrong parameters" do
    server = servers(:heinz)
    patch :update, params: { id: server.id, server: { firstname: '', lastname: '', email: 'testbla.de', sex: nil, size_talar: 200, size_rochet: 20, rank: nil }}
    assert_response :success
    assert_template :edit
    assert_equal server, assigns(:server)
    assert_select '.server_firstname.has-error .help-block'
    assert_select '.server_lastname.has-error .help-block'
    assert_select '.server_email.has-error .help-block'
    assert_select '.server_sex.has-error .help-block'
    assert_select '.server_size_talar.has-error .help-block'
    assert_select '.server_size_rochet.has-error .help-block'
    assert_select '.server_rank.has-error .help-block'
  end

  test "update invalid parameter" do
    server = servers(:heinz)
    used = server.last_used
    seed = server.seed
    patch :update, params: { id: server.id, server: { last_used: DateTime.now, seed: '12345678901234567890af1234567890' }}
    assert_redirected_to admin_servers_path
    server = Server.find(server.id)
    assert_equal used, server.last_used
    assert_equal seed, server.seed
  end

  test "update valid parameters" do
    old = servers(:heinz)
    patch :update, params: { id: old.id, server: { firstname: 'test', lastname: 'teste', email: 'test@blablabla.de', birthday: 2.days.ago, sex: :female, size_talar: 150, size_rochet: 90, since: 1.day.ago, rank: :master }}
    assert_redirected_to admin_servers_path
    new = Server.find(old.id)
    assert_not_equal old.firstname, new.firstname
    assert_equal 'test', new.firstname
    assert_not_equal old.lastname, new.lastname
    assert_equal 'teste', new.lastname
    assert_not_equal old.email, new.email
    assert_equal 'test@blablabla.de', new.email
    assert_not_equal old.birthday, new.birthday
    assert_equal 2.days.ago.to_date, new.birthday
    assert_not_equal old.sex, new.sex
    assert_equal 'female', new.sex
    assert_not_equal old.size_talar, new.size_talar
    assert_equal 150, new.size_talar
    assert_not_equal old.size_rochet, new.size_rochet
    assert_equal 90, new.size_rochet
    assert_not_equal old.since, new.since
    assert_equal 1.day.ago.to_date, new.since
    assert_not_equal old.rank, new.rank
    assert_equal 'master', new.rank
  end

  test "update user" do
    server = servers(:heinz)
    user = users(:max)
    patch :update, params: { id: server.id, server: { user_id: user.id }}
    assert_redirected_to admin_servers_path
    assert_includes user.servers.reload, server
  end

  test "deleting server" do
    server = servers(:heinz)
    delete :destroy, params: { id: server.id }
    assert_redirected_to admin_servers_path
    assert_not Server.find_by(id: server.id)
  end

  test "show new server form" do
    get :new
    assert_response :success
    assert_template :new
    assert assigns(:server)
  end

  test "create server" do
    assert_difference 'Server.all.count', +1 do
      post :create, params: { server: { firstname: 'test', lastname: 'bla', email: 'test@bla.de', sex: :male }}
    end
    assert_redirected_to admin_servers_path
  end

  test "create server with error" do
    assert_no_difference 'Server.all.count' do
      post :create, params: { server: { firstname: 'test', lastname: 'bla', email: 'testbla.de', sex: :male }}
    end
    assert_response :success
    assert_template :new
    assert_select '.server_email.has-error .help-block'
  end

end
