require 'test_helper'

class ServerTest < ActiveSupport::TestCase

  def setup
    @fname = { firstname: 'Max' }
    @lname = { lastname: 'Mustermann' }
    @name = {**@fname, **@lname}
    @email = { email: 'max@mustermann.de' }
    @sex = { sex: :male }
    @all = { **@name, **@email, **@sex }
  end

  test "mandatory fields firstname, lastname, sex and email given" do
    server = Server.new(**@lname, **@email, **@sex)
    assert_not server.valid?, "No firstname given"
    server = Server.new(**@fname, **@email, **@sex)
    assert_not server.valid?, "No lastname given"
    server = Server.new(**@name, **@sex)
    assert_not server.valid?, "No email given"
    server = Server.new(**@name, **@email)
    assert_not server.valid?, "No sex given"
    server = Server.new(@all)
    assert server.valid?, "Everything mandatory given but still not valid?"
  end

  test "names shouldn't be blank" do
    server = Server.new(firstname: '    ', **@lname, **@email, **@sex)
    assert_not server.valid?, "Firstname was blank"
    server = Server.new(**@fname, lastname: '   ', **@email, **@sex)
    assert_not server.valid?, "Lastname was blank"
  end

  test "email should be valid" do
    server = Server.new(**@name, **@sex, email: 'Test')
    assert_not server.valid?, "Email was not valid"
  end

  test "email should be saved lowercase" do
    server = Server.new(**@name, **@sex, email: 'Test@BlA.DE')
    assert server.save
    assert_equal 'test@bla.de', server.email, "email isn't saved lowercase"
    server.destroy

    server = Server.new(**@name, **@sex, email: 'test@bla.de')
    assert server.save
    assert_equal 'test@bla.de', server.email, "email isn't kept lowercase"
    server.destroy
  end

  test "email of server with user should be that of the user" do
    assert_equal users(:max).email, servers(:max).email, "Email of server should be that of the user"
    assert_equal 'heinz@gianfelice.de', servers(:heinz).email, "Email of server without user should be normal"
  end

  test "sex should be valid" do
    server = servers(:max)

    server.update(sex: nil)
    assert_not (server.male? and server.female?), "Sex was not set to nil correctly"
    server.update(sex: :male)
    assert server.male?, "Sex male wasn't saved correctly"
    server.update(sex: :female)
    assert server.female?, "Sex female wasn't saved correctly"

    assert_raises(ArgumentError) do
      server.update(sex: 3)
    end

    Server.all.each do |server|
      assert_includes [:male.to_s, :female.to_s, nil], server.sex, "Invalid sex saved"
    end
  end

  test "rank should be valid" do
    server = servers(:max)

    Server.ranks.keys.each do |rank|
      server.update(rank: rank)
      assert_equal rank.to_s, server.rank, "Rank was not saved correctly"
    end

    server.rank = nil
    assert_not server.valid?, "Rank should not be nil"

    assert_raises(ArgumentError) do
      server.update(rank: 10)
    end
  end

  test "sizes should be numerically and in range" do
    server = servers(:max)

    server.size_talar = 99
    assert_not server.valid?, "size_talar is too small"
    server.size_talar = 151
    assert_not server.valid?, "size_talar is too big"
    server.size_talar = 'test'
    assert_not server.valid?, "size_talar is not a number"
    server.size_talar = 130.5
    assert_not server.valid?, "size_talar is not an integer"
    server.size_talar = 140
    assert server.valid?, "size_talar should be valid"

    server.size_rochet = 59
    assert_not server.valid?, "size_rochet is too small"
    server.size_rochet = 101
    assert_not server.valid?, "size_rochet is too big"
    server.size_rochet = 'test'
    assert_not server.valid?, "size_rochet is not a number"
    server.size_rochet = 80.5
    assert_not server.valid?, "size_rochet is not an integer"
    server.size_rochet = 90
    assert server.valid?, "size_rochet should be valid"
  end

  test "seed should be generated on user-creation" do
    server = Server.create(**@all)
    seed = server.seed
    assert_not_nil seed, "server seed shouldn't be empty"
    assert_not_empty seed, "server seed shouldn't be empty"

    server.generate_seed
    assert_not_equal seed, server.seed, "new seed should have been generated"

    id = servers(:max).id
    seed = Server.find(id).seed
    assert_equal seed, Server.find(id).seed, "seed should not be generated newly each time"
  end

  test "seed should be unique" do
    seed = servers(:max).seed
    server = servers(:heinz)
    assert_not server.update(seed: seed), "seed should be unique"
  end

  test "seed length 16" do
    server = servers(:max)
    server.seed = "1234567890123456789012345678901"
    assert_not server.valid?, "seed to short"
    server.seed = "12345678901234567890123456789012"
    assert server.valid?, "seed has right length, shouldn't fail"
    server.seed = "123456789012345678901234567890123"
    assert_not server.valid?, "seed to long"
  end

  test "seed hexanumerical" do
    server = servers(:max)
    server.seed = "1234567890123456789012345678901g"
    assert_not server.valid?, "seed contains non-hexanumerical character"
    server.seed = "abcdef1234567890abcdef1234567890"
    assert server.valid?, "seed should be valid, contains only hexanumerical characters"
  end

  test "email should only be mandatory if no user" do
    user = users(:max)
    server = Server.new(**@name, **@sex, user: user)
    assert server.valid?, "email should not be required if user given"
  end

  test "save last used timestamp" do
    server = servers(:max)
    used = server.last_used
    server.used
    assert_not_equal used, server.last_used, "Date didn't change"
  end

  test "string reprensentation should be full name" do
    server = servers(:max)
    name = server.firstname + ' ' + server.lastname
    assert_equal name, server.to_s, "String representation should be name"
  end

  test "unlink server from user" do
    server = servers(:heinz)
    user = users(:max)
    assert_not_equal server.email, user.email
    assert server.update(user_id: user.id)
    assert_equal user, server.user, "User wasn't linked correctly"
    server.unlink_user
    assert_nil server.user_id
    assert_equal user.email, server.email, "Email was not correctly forwarded to server"
  end

  test "get other managable servers of server" do
    # User-managed server
    server = servers(:max)
    others = server.user.servers.where.not(id: server.id).to_a
    assert_equal others, server.siblings

    # Server without user
    server = servers(:heinz)
    others = Server.where(email: server.email, user_id: nil).where.not(id: server.id).to_a
    assert_equal others, server.siblings

    # Server with nothing else
    assert_empty servers(:kunz).siblings
  end

  test "Have a server enroll to multiple events" do
    evts = [ events(:easter), events(:goodfriday) ]
    server = servers(:max)
    assert server.update(events: evts)
    assert server.valid?
    assert_equal evts, server.events.reload
  end

  test "Shortnames are unique and as short as possible" do
    shortnames = {
      max: 'Max Mustermann',
      heinz: 'Heinz',
      kunz: 'Kunz Hinz',
      admin: 'Admin',
      shortkunz: 'Kunz Hind.',
      shortmax: 'Max S.',
      maxcopy: 'Max Mustermann'
    }

    shortnames.each do |key, value|
      assert_equal value, servers(key).shortname
    end
  end

  test "The server can be subscribed to multiple messages" do
    msgs = [ messages(:one), messages(:two) ]
    server = servers(:max)
    assert server.update(messages: msgs)
    assert server.valid?
    assert_equal msgs, server.messages
  end

  test "Receive login token of server" do
    assert_equal users(:max).email, servers(:max).login_token
    assert_equal servers(:heinz).seed, servers(:heinz).login_token
  end

  test "Should not receive any errors directly after creation" do
    server = Server.new
    assert_empty server.errors
  end

  test "Servers can enroll for mutiple plans" do
    plans = Plan.all
    server = servers(:max)
    assert server.update(plans: plans)
    assert_equal plans, server.plans.reload
  end

end
