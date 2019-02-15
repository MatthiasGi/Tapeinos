class AddApiKeyToServers < ActiveRecord::Migration[5.1]
  def change
    add_column :servers, :api_key, :string

    change_table :servers do |t|
      t.index :api_key, unique: true, allow_nil: true
    end
  end
end
