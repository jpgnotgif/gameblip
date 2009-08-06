class CreatePlaystationConsoleUsers < ActiveRecord::Migration
  def self.up
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
  end

  def self.down
    drop_table :playstation_console_users
  end
end
