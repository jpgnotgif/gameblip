class CreateStiForGamerIdentities < ActiveRecord::Migration
  def self.up
    create_table :gamer_identities do |t|
      t.references :user
      t.references :category
      t.string :name
      t.string :type
      t.string :avatar_url
      t.boolean :online
      t.string :country
    end
    drop_table :xbox_console_users
    drop_table :playstation_console_users
  end

  def self.down
    create_table :playstation_console_users do |t|
      t.references :user
      t.string :psn_id
      t.string :rank
      t.string :avatar_url
      t.datetime :registered_at
      t.boolean :online
      t.string :country
      t.timestamps
    end
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
    drop_table :gamer_identities
  end
end
