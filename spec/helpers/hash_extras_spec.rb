require File.dirname(__FILE__) + '/../spec_helper'
require "hash_extras"

describe HashExtras do
  before :each do
    @single_level_hash = {
      "BatmanAndRobin" => "dynamic_duo", 
      "SpamAndEggs" => "delicious"
    }
    @multilevel_hash = {
      "DCVillains" => {
        "TheJoker" => {
          "HarleyQuinn" => "sidekick",
          "TheClownPrinceOfCrime" => true
        }, 
        "MrFreeze" => "cold_blooded"
      },
      "DCHeroes" => {
        "BoosterGold" => "golden",
        "JusticeLeague" => {
          "Superman" => "Man of Steel",
          "Batman" => "Dark Knight",
          "MartianManhunter" => {
            "MarsMan" => true,
            "SuperHero" => true
          }
        }
      }
    }
  end

  # TODO: Replace with custom rspec matchers
  it "should convert single level hash keys" do
    converted_hash = HashExtras.underscorize_and_symbolize_all_keys!(@single_level_hash)
    converted_hash.keys.include?(:batman_and_robin).should be_true
    converted_hash.keys.include?("BatmanAndRobin").should be_false
    converted_hash.keys.include?(:spam_and_eggs).should be_true
    converted_hash.keys.include?("SpamAndEggs").should be_false
  end

  it "should convert multi level hash keys" do
    converted_hash = HashExtras.underscorize_and_symbolize_all_keys!(@multilevel_hash)
    converted_hash.keys.include?()
  end
end
