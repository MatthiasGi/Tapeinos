class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :subject
      t.text :text
      t.datetime :date
      t.integer :state, null: false, default: 0

      t.integer :user_id

      t.timestamps null: false
    end

    add_index :messages, :user_id
  end
end
