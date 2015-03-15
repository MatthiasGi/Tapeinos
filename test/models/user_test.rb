require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @password = { password: 'testen' }
    @email = { email: 'test@bla.de' }
  end

  test "email and password must be present" do
    user = User.new
    assert_not user.valid?, "email isn't mandatory"
    user = User.new(**@email)
    assert_not user.valid?, "password isn't mandatory"
    user = User.new(**@email, **@password)
    assert user.valid? , "email and password aren't enough?"
  end

  test "password shouldn't be blank" do
    user = User.new(**@email, password: "          ")
    assert_not user.valid?, "password is blank"
  end

  test "email should contain an @ to prevent typos" do
    user = User.new(email: 'testing', **@password)
    assert_not user.valid?, "email doesn't contain an @"
    user = User.new(email: 'test@bla', **@password)
    assert user.valid?, "email contains an @ and thus should be accepted"
  end

  test "email should be unique" do
    user1 = User.new(email: 'test@bla.de', **@password)
    assert user1.save
    user2 = user1.dup
    assert_not user2.save, "user with given email already exists"
    user3 = User.new(email: 'Test@BlA.DE', **@password)
    assert_not user3.save, "user with given case-insensitve email already exists"
    user1.destroy
  end

  test "email should be saved lowercase" do
    user = User.new(email: 'Test@BlA.DE', **@password)
    assert user.save
    assert_equal 'test@bla.de', user.email, "email isn't saved lowercase"
    user.destroy

    user = User.new(email: 'test@bla.de', **@password)
    assert user.save
    assert_equal 'test@bla.de', user.email, "email isn't kept lowercase"
    user.destroy
  end

  test "password_confirmation should match password" do
    user = User.new(**@email, password: 'testen', password_confirmation: 'test')
    assert_not user.valid? "passwords do not match"
    user = User.new(**@email, password: 'testen', password_confirmation: 'testen')
    assert user.valid? "passwords do match but still not valid"
  end

  test "password length minimum 6" do
    user = User.new(**@email, password: 'teste')
    assert_not user.valid?, "password is too short"
    user = User.new(**@email, password: 'testen')
    assert user.valid?, "password is long enough"
  end

  test "user authenticates with right password" do
    user = users(:max)
    assert_not user.authenticate('wrongpassword'), "passwort is wrong"
    assert user.authenticate('testen'), "password is right but not recognised"
  end

  test "save last used timestamp" do
    user = users(:max)
    used = user.last_used
    user.used
    assert_not_equal used, user.last_used, "Date didn't change"
  end

  test "string reprensentation should be email" do
    user = users(:max)
    assert_equal user.email, user.to_s, "String representation should be email"
  end

  test "password only validated if given" do
    user = users(:max)
    assert user.valid?, "Validation of fixed user failed"
  end

  test "generate password reset hash with expiration ≈24h" do
    user = users(:max)
    token = user.prepare_password_reset
    assert_equal user, User.find_by(password_reset_token: token), "User could not be found through token #{token}"
    assert user.password_reset_expire > 23.hours.from_now, "Expiration-time to small"
    assert user.password_reset_expire <= 1.day.from_now, "Expiration-time to long"

    assert_not user.password_reset_expired?, "Should not have been expired"
    user.password_reset_expire = 1.second.ago
    assert user.password_reset_expired?, "Should now display as expired"

    user.clear_password_reset
    assert_nil user.password_reset_token || user.password_reset_expire, "Password reset still possible?"
    assert user.password_reset_expired?, "Should be expired if not in reset-mode"
  end

  test "edit information of server linked to user" do
    user = users(:max)
    server = user.servers.first
    assert user.update(servers_attributes: {id: server.id, firstname: 'Test'}), "Should save nested attributes"
    server = Server.find(server.id)
    assert_equal 'Test', server.firstname, "Updated Attribute not saved correctly"
    server.update(firstname: 'Max')
  end

  test "deleting the user should update the user by getting the old email" do
    servers = []
    email = 'testen@testen.testen.de'
    user = User.new(email: email, password: 'testen')
    assert user.valid?
    3.times do |i|
      servers << Server.new(firstname: "first_#{i}", lastname: "last_#{i}", email: "test@bla#{i}.de", sex: :male, user: user)
    end

    user.destroy
    assert_not User.find_by(email: email)

    servers.each do |s|
      server = Server.find(s.id)
      assert_not server.user_id, "User was not removed from server"
      assert_equal email, server.email, "Email was not propragated on deletion of user #{server.inspect}"
    end
  end

  test "update failed password attempts" do
    user = users(:max)
    user.failed_authentication
    user = User.find(user.id)
    assert_equal 1, user.failed_authentications

    3.times do
      user.failed_authentication
    end
    assert_not user.blocked?
    user.failed_authentication
    assert user.blocked?

    user.clear_password_reset
    assert_equal 0, user.failed_authentications
  end

end
