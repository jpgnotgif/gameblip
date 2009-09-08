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
        "JusticeLeague" => {
          "Superman" => "Man of Steel",
          "Batman" => {
            "DarkKnight" => true,
            "BruceWayne" => true,
          }
        }
      }
    }
  end

  it "should convert single level hash keys" do
    converted_hash = HashExtras.underscorize_and_symbolize_all_keys!(@single_level_hash)

    converted_hash.should have_key(:batman_and_robin)
    converted_hash.should_not have_key("BatmanAndRobin")

    converted_hash.should have_key(:spam_and_eggs)
    converted_hash.should_not have_key("SpamAndEggs")
  end

  it "should convert multi level hash keys" do
    converted_hash = HashExtras.underscorize_and_symbolize_all_keys!(@multilevel_hash)

    converted_hash.should have_key(:dc_villains)
    converted_hash.should_not have_key("DCVillains")
    converted_hash.should have_key(:dc_heroes)
    converted_hash.should_not have_key("DCHeroes")

    dc_villains_hash = converted_hash[:dc_villains]    
    dc_villains_hash.should have_key(:the_joker)
    dc_villains_hash.should_not have_key("TheJoker")
    dc_villains_hash.should have_key(:mr_freeze)
    dc_villains_hash.should_not have_key("MrFreeze")

    the_joker_hash = dc_villains_hash[:the_joker]
    the_joker_hash.should have_key(:harley_quinn)
    the_joker_hash.should have_key(:the_clown_prince_of_crime)
    
    dc_heroes_hash = converted_hash[:dc_heroes]
    dc_heroes_hash.should have_key(:justice_league)
    dc_heroes_hash.should_not have_key("JusticeLeague")
    
    justice_league_hash = dc_heroes_hash[:justice_league]

    justice_league_hash.should have_key(:batman)
    justice_league_hash.should_not have_key("Batman")

    batman_hash = justice_league_hash[:batman]
    batman_hash.should have_key(:dark_knight)
    batman_hash.should_not have_key("DarkKnight")
    batman_hash.should have_key(:bruce_wayne)
    batman_hash.should_not have_key("BruceWayne")    
  end
end
