class CreateUserProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :user_profiles do |t|
      t.references :user, null: true, foreign_key: true
      t.references :campaign, null: false, foreign_key: true
      t.references :reward, null: true, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :ip_address
      t.text :location_address
      t.string :status, default: 'draft'
      t.string :otp_code
      t.datetime :otp_expires_at
      t.integer :otp_attempts, default: 0
      t.text :feedback

      t.timestamps
    end
  end
end
