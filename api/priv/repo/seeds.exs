# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CecrUnwomen.Repo.insert!(%CecrUnwomen.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CecrUnwomen.Repo
alias CecrUnwomenWeb.Models. { Role, ScrapConstantFactor, HouseholdConstantFactor }

# Seed role
Repo.delete_all(Role)
roles = [
  %Role{ id: 1, name: "Admin", description: "Manage user" },
  %Role{ id: 2, name: "Household", description: "Need to fill a form to prove contribution of household to environment" },
  %Role{ id: 3, name: "Scraper", description: "Need to fill a form to prove contribution of scraper to environment" }
]
Enum.each(roles, &Repo.insert!(&1))

# Seed household factor
household_factors = [
  %HouseholdConstantFactor{ name: "one_plastic_bag_rejected", value: 0.001578, unit: "kg CO2e" },
  %HouseholdConstantFactor{ name: "one_pet_bottle_rejected", value: 0.08, unit: "kg CO2e" },
  %HouseholdConstantFactor{ name: "one_plastic_cup_rejected", value: 0.05, unit: "kg CO2e" },
  %HouseholdConstantFactor{ name: "one_plastic_straw_rejected", value: 0.00146, unit: "kg CO2e" },

  %HouseholdConstantFactor{ name: "one_kilo_plastic_recycled", value: 1.64, unit: "kg CO2e" },
  %HouseholdConstantFactor{ name: "one_kilo_paper_recycled", value: 3.9, unit: "kg CO2e" },
  %HouseholdConstantFactor{ name: "one_kilo_metal_garbage_recycled", value: 6.79, unit: "kg CO2e" },
  %HouseholdConstantFactor{ name: "one_kilo_organic_garbage_to_fertilizer", value: 2.15, unit: "kg CO2e" },
]
Enum.each(household_factors, &Repo.insert!(&1))

# Seed scrap factor
scrap_factors = [
  %ScrapConstantFactor{ name: "one_kilo_plastic_collected", value: 1.64, unit: "kg CO2e" },
  %ScrapConstantFactor{ name: "one_kilo_paper_collected", value: 3.9, unit: "kg CO2e" },
  %ScrapConstantFactor{ name: "one_kilo_metal_garbage_collected", value: 6.79, unit: "kg CO2e" },
  %ScrapConstantFactor{ name: "one_kilo_expense_collected", value: 349.72, unit: "VNĐ/kg" },
]
Enum.each(scrap_factors, &Repo.insert!(&1))
