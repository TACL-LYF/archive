class AddCovidVaccinatedToRegistrations < ActiveRecord::Migration[5.2]
  def up
    add_column :registrations, :covid_vaccinated, :boolean, default: false
  end

  def down
    remove_column :registrations, :covid_vaccinated, :boolean
  end
end
