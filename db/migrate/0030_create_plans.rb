class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.string :title, null: false
      t.text :remark

      t.timestamps null: false
    end
  end
end
