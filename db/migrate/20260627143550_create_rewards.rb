class CreateRewards < ActiveRecord::Migration[7.2]
  def change
    create_table :rewards do |t|
      t.references :campaign, null: false, foreign_key: true
      t.string :reward_type
      t.string :name
      t.text :description
      t.integer :stock, default: 0

      t.timestamps
    end
  end
end
