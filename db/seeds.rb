# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create({email: 'matthias@gianfelice.de', password: 'testen'})
User.create({email: 'heinz@gianfelice.de', password: 'testen'})

['Max', 'Heinz'].each do |name|
  Server.create(firstname: name, lastname: 'Gianfelice', user: user)
end
Server.create(firstname: 'Matthias', lastname: 'Gianfelice', seed: '12345678901234567890123456789012', user: user)

Server.create(firstname: 'Stand', lastname: 'Alone', email: 'standalone@gianfelice.de', seed: '1234567890abcdef1234567890abcdef')

Server.create(firstname: 'Siblin1', lastname: 'Sibling', email: 'siblings@gianfelice.de', seed: '09876543210987654321098765432109')
Server.create(firstname: 'Siblin2', lastname: 'Sibling', email: 'siblings@gianfelice.de', seed: '19876543210987654321098765432109')
