class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :subject, null: false
      t.text :text, null: false
      t.datetime :date, null: false
      t.integer :state, null: false, default: 0

      t.integer :user_id, null: false

      t.timestamps null: false
    end

    add_index :messages, :user_id
  end
end
