class CreateXboxConsoleUsers < ActiveRecord::Migration
  def self.up
    create_table :xbox_console_users do |t|
      t.references :user
      t.string :account_status
      t.string :status
      t.string :gamertag
      t.integer :gamerscore
      t.string :motto
      t.string :avatar_url
      t.string :location
      t.string :country
      t.string :reputation_url
      t.string :zone
      t.string :recent_activity
      t.datetime :last_seen_at
      t.boolean :online
      t.timestamps
    end
  end

  def self.down
    drop_table :xbox_console_users
  end
end
