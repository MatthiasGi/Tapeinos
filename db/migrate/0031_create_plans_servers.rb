class CreatePlansServers < ActiveRecord::Migration
  def change
    create_table :plans_servers, id: false do |t|
      t.belongs_to :plan, index: true
      t.belongs_to :server, index: true
    end
  end
end
