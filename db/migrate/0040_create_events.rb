class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.datetime :date, null: false
      t.string :title
      t.string :location
      t.integer :needed, null: false, default: 1

      t.integer :plan_id, null: false

      t.timestamps null: false
    end

    add_index :events, :plan_id
  end
end
