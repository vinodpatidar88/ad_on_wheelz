class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :phone_number
      t.boolean :verified, default: false

      t.timestamps
    end
    add_index :users, :phone_number, unique: true
  end
end
