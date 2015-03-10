class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.datetime :date
      t.string :title
      t.string :location

      t.integer :plan_id, null: false

      t.timestamps null: false
    end

    add_index :events, :plan_id
  end
end
