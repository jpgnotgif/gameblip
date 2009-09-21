class ModifyGamerIdentities < ActiveRecord::Migration
  def self.up
    change_table :gamer_identities do |t|
      t.remove :motto
      t.rename :country, :location
    end
  end

  def self.down
    change_table :gamer_identities do |t|
      t.rename :location, :country
      t.string :motto
    end
  end
end
