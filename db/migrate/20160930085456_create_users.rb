class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.integer :gamebus_id, index: true
      t.integer :rvs_id, index: true
      t.string :synced_scores, array: true, default: []
      t.string :gamebus_key
      t.string :rvs_key
      t.timestamps
    end
  end
end
