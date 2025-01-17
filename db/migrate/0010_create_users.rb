class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, unique: true
      t.string :password_digest, null: false

      t.datetime :last_used

      t.integer :role, null: false, default: 0

      t.string :password_reset_token, unique: true
      t.datetime :password_reset_expire
      t.integer :failed_authentications, null: false, default: 0

      t.timestamps null: false
    end

    add_index :users, :email
  end
end
