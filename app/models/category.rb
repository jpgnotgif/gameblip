class Category < ActiveRecord::Base
  belongs_to :avatar, :polymorphic => true
end
