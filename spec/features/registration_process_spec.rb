require 'rails_helper'

RSpec.feature "RegistrationProcess", type: :feature do
  background do
    visit "/registration"
  end

  def fill_form(fields = {})
    fields.each do |field, value|
      fill_in field.to_s.titlecase, with: value
    end
  end

  scenario "Step 0: User visits registration page" do
    expect(page).to have_content "Register for LYF Camp"

    feature "Step 1: Parent Information" do
      background do
        click_link "Get Started"
      end

      scenario "User is on Parent Information step" do
        expect(page).to have_text "Parent/Guardian Information"
      end

      fill_form parent_first_name: "Jonathan",
                parent_last_name: "Chen",
                parent_email: "jonathan.chen@example.net",
                parent_phone_number: "5102345678"

      click_button "Continue"
      expect(page).to have_text "errors"

      fill_form street_address: "1234 Main St.",
                city: "San Jose",
                state: "CA",
                zip: "95132"
      click_button "Continue"
      expect(page).to have_text "Camper Information"
    end
  end
end
