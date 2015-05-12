# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create({email: 'matthias@gianfelice.de', password: 'testen', role: :root})
User.create({email: 'heinz@gianfelice.de', password: 'testen'})

['Max', 'Heinz'].each do |name|
  Server.create(firstname: name, lastname: 'Gianfelice', user: user, sex: :male)
end
Server.create(firstname: 'Matthias', lastname: 'Gianfelice', seed: '12345678901234567890123456789012', user: user, sex: :male)

Server.create(firstname: 'Stand', lastname: 'Alone', email: 'standalone@gianfelice.de', seed: '1234567890abcdef1234567890abcdef', sex: :female)

Server.create(firstname: 'Siblin1', lastname: 'Sibling', email: 'siblings@gianfelice.de', seed: '09876543210987654321098765432109', sex: :female)
Server.create(firstname: 'Siblin2', lastname: 'Sibling', email: 'siblings@gianfelice.de', seed: '19876543210987654321098765432109', sex: :female)

plan = Plan.create(title: 'Easter', remark: 'This is a demo remark about how great Tapeinos is.')
Event.create(date: '2015-04-02 19:30:00', title: 'Holy Thursday', location: 'EK', plan: plan)
Event.create(date: '2015-04-03 15:00:00', title: 'Good Friday', location: 'LK', plan: plan)
Event.create(date: '2015-04-04 21:00:00', title: 'Easter', plan: plan)
Event.create(date: '2015-04-05 10:30:00', plan: plan)
Event.create(date: 2.weeks.from_now, plan: plan)

text = "**Test** %{firstname}\n\n %{login}"
Message.create(subject: 'Testsubject Last', date: 2.days.ago, text: text, user: user)
Message.create(subject: 'Testsubject First', date: 1.day.ago, text: text, user: user, state: :sent)
Message.create(subject: 'Another Test', date: 5.minutes.ago, text: text, user: user, plan: plan)

