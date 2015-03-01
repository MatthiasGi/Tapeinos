class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :firstname, null: false
      t.string :lastname, null: false
      t.string :email
      t.date :birthday
      t.integer :sex
      t.integer :size_talar
      t.integer :size_rochet

      t.integer :rank, default: 0, null: false
      t.datetime :last_used

      t.string :seed, unique: true

      t.integer :user_id

      t.timestamps null: false
    end

    add_index :servers, :user_id
    add_index :servers, :seed
  end
end
