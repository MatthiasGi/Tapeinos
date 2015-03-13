class CreateEventsServers < ActiveRecord::Migration
  def change
    create_table :events_servers, id: false do |t|
      t.belongs_to :event, index: true
      t.belongs_to :server, index: true
    end
  end
end
