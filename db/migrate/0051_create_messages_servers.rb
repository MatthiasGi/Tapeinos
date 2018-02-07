class CreateMessagesServers < ActiveRecord::Migration[5.1]
  def change
    create_table :messages_servers, id: false do |t|
      t.belongs_to :message, index: true
      t.belongs_to :server, index: true
    end
  end
end
