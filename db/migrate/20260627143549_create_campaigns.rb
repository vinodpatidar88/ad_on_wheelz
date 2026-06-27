class CreateCampaigns < ActiveRecord::Migration[7.2]
  def change
    create_table :campaigns do |t|
      t.references :sub_category, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :qr_token
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
    add_index :campaigns, :qr_token, unique: true
  end
end
