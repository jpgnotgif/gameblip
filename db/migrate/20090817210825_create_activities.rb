class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.references :avatar, :polymorphic => true
      t.string :description, :limit => 256
      t.datetime :created_at  
    end
  end

  def self.down
    drop_table :activities
  end
end
