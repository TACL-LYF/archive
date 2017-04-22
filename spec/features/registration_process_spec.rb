require 'rails_helper'

RSpec.feature "RegistrationProcess", type: :feature, js: true do
  include ActiveSupport::Testing::TimeHelpers
  before { travel_to Date.new(2017,01,02) }
  after { travel_back }

  def fill_form(fields = {})
    fields.each do |field, value|
      fill_in field.to_s, with: value
    end
  end

  def expect_filled_fields(fields = {})
    fields.each do |field, value|
      expect(page).to have_field field, with: value
    end
  end

  def expect_no_error_messages
    expect(page).to have_no_content "error"
    expect(page).to have_no_content "Oops! Something went wrong"
  end

  describe "User visits registration page" do
    background do
      # populate test db
      detailed = ["TACL-LYF Counselors", "TACL-LYF Campers and Families",
        "Other Taiwanese Organizations", "Other"]
      ["TACL-LYF Counselors", "TACL-LYF Campers and Families", "JTASA", "TAP",
        "Other Taiwanese Organizations", "Chinese School", "Newspaper", "Flyers",
        "Facebook", "Other"].each do |method|
        ReferralMethod.create!(name: method, allow_details: detailed.include?(method))
      end

      # make current camp
      Camp.create!(year: 2017, name: "To Be Determined",
        registration_fee: 680, registration_late_fee: 40, sibling_discount: 40,
        shirt_price: 15, registration_open_date: Date.new(2016,12,01),
        registration_late_date: Date.new(2017,04,01),
        registration_close_date: Date.new(2017,05,01))

      visit "/registration"
    end

    it "displays registration information" do
      expect(page).to have_content "Register for LYF Camp"
      expect(page).to have_content "General Registration"
      expect(page).to have_content "Late Registration"
      expect(page).to have_content "$"
      expect(page).to have_link "Registration Policy"
      expect(page).to have_link "Discounts & Financial Aid"
      expect(page).to have_link "Get Started"
      expect_no_error_messages
    end

    describe "User clicks \"Get Started \" button" do
      background { click_link "Get Started" }

      it "shows Parent page" do
        expect(page).to have_text "Parent/Guardian Information"
        expect(page).to have_text "Secondary Parent Contact Information"
        expect_no_error_messages
      end

      describe "User clicks Continue on Parent page" do
        context "when field values are invalid" do
          background do
            click_button "Continue"
          end

          it "re-renders Parent page wth error messages" do
            expect(page).to have_text "Parent/Guardian Information"
            expect(page).to have_text "8 errors occurred"
          end
        end

        context "when parent field values are valid" do
          background do
            fill_form "Parent First Name": "Jonathan",
                      "Parent Last Name": "Chen",
                      "Parent Email": "jonathan.chen@example.net",
                      "Parent Phone Number": "5102345678",
                      "First Name": "Jessica",
                      "Last Name": "Chen",
                      "Email": "jessica.chen@example.net",
                      "Phone Number": "5109876543",
                      "Street Address": "1234 Main St.",
                      "Apt/Suite": "123",
                      "City": "San Jose",
                      "State": "CA",
                      "Zip": "95132"
            click_button "Continue"
          end

          it "continues to referral page" do
            expect(page).to have_text "How did you hear about us?"
            expect_no_error_messages
          end

          describe "User clicks Back on Referral page" do
            background { click_link "Back" }

            it "returns to Parent page with fields filled" do
              expect_no_error_messages
              expect(page).to have_text "Parent/Guardian Information"
              expect_filled_fields "Parent First Name": "Jonathan",
                                   "Parent Last Name": "Chen",
                                   "Parent Email": "jonathan.chen@example.net",
                                   "Parent Phone Number": "5102345678",
                                   "First Name": "Jessica",
                                   "Last Name": "Chen",
                                   "Email": "jessica.chen@example.net",
                                   "Phone Number": "5109876543",
                                   "Street Address": "1234 Main St.",
                                   "Apt/Suite": "123",
                                   "City": "San Jose",
                                   "State": "CA",
                                   "Zip": "95132"
              expect_no_error_messages
            end
          end

          describe "User clicks Continue on Referral page" do
            background do
              (0..9).to_a.each do |n|
                check "family_referrals_attributes_#{n}__destroy"
                if [0,1,4,9].include? n
                  fill_in "family_referrals_attributes_#{n}_details",
                          with: "Referrer #{n}"
                end
              end

              click_button "Continue"
            end

            it "continues to Camper page" do
              expect(page).to have_text "Camper First Name"
              expect_no_error_messages
            end

            describe "User clicks Back on Camper page" do
              background { click_link "Back" }

              it "returns to Parent page with checkboxes checked" do
                expect_no_error_messages
                expect(page).to have_text "How did you hear about us?"
                (0..9).to_a.each do |n|
                  expect(page).to have_checked_field "family_referrals_attributes_#{n}__destroy"
                  if [0,1,4,9].include? n
                    expect(page).to have_field "family_referrals_attributes_#{n}_details",
                      with: "Referrer #{n}"
                  end
                end
              end
            end

            describe "User clicks Continue on Camper page" do
              context "when field values are invalid" do
                background do
                  click_button "Continue"
                end

                it "re-renders Camper page with error messages" do
                  expect(page).to have_text "Camper First Name"
                  expect(page).to have_text "9 errors occurred"
                end
              end

              context "when camper field values are valid" do
                background do
                  fill_form "Camper First Name": "Jeffrey",
                            "Camper Last Name": "Chen",
                            "Camper Email": "jeffrey.chen@example.net",
                            "Medical Conditions and Medication": "N/A",
                            "Diet Considerations and Food Allergies": "N/A"
                  select "January", from: "camper_birth_month"
                  select "1", from: "camper_birth_day"
                  select "2000", from: "camper_birth_year"
                  choose "camper_gender_male"
                  choose "camper_returning_true"
                  click_button "Continue"
                end

                it "continues to Details page" do
                  expect_no_error_messages
                  expect(page).to have_text "Registration Details"
                end

                describe "User clicks Back on Details page" do
                  background { click_link "Back" }

                  it "returns to Camper page with fields filled" do
                    expect_no_error_messages
                    expect(page).to have_text "Camper First Name"
                    expect_filled_fields "Camper First Name": "Jeffrey",
                                         "Camper Last Name": "Chen",
                                         "Camper Email": "jeffrey.chen@example.net",
                                         "Medical Conditions and Medication": "N/A",
                                         "Diet Considerations and Food Allergies": "N/A"
                    expect(page).to have_select "camper_birth_month", selected: "January"
                    expect(page).to have_select "camper_birth_day", selected: "1"
                    expect(page).to have_select "camper_birth_year", selected: "2000"
                    expect(page).to have_checked_field "camper_gender_male"
                    expect(page).to have_checked_field "camper_returning_true"
                  end
                end

                describe "User clicks Continue on Details page" do
                  context "when registration detail fields are invalid" do
                    background { click_button "Continue" }

                    it "re-renders the page with error messages" do
                      expect(page).to have_text "Registration Details"
                      expect(page).to have_text "3 errors occurred"
                    end
                  end

                  context "when registration detail fields are valid" do
                    background do
                      select "10th", from: "Camper Grade"
                      select "Small", from: "T-shirt Size"
                      fill_form "X Small": 1,
                                "Small": 2,
                                "Medium": 3,
                                "Large": 4,
                                "X Large": 5,
                                "XX Large": 6,
                                "Please provide your high school below.": "Lynbrook High School"
                      choose "registration_bus_true"
                      click_button "Continue"
                    end

                    it "continues to Camper Roles page" do
                      expect_no_error_messages
                      expect(page).to have_text "Camper Involvement"
                      # TODO: test new camper/camper not old enough path
                    end

                    describe "User clicks Back on Camper Roles page" do
                      background { click_link "Back" }

                      it "returns to Details page with fields filled" do
                        expect_no_error_messages
                        expect(page).to have_text "Registration Details"
                        expect(page).to have_select "Camper Grade", selected: "10th"
                        expect(page).to have_select "T-shirt Size", selected: "Small"
                        expect_filled_fields "X Small": 1,
                                             "Small": 2,
                                             "Medium": 3,
                                             "Large": 4,
                                             "X Large": 5,
                                             "XX Large": 6,
                                             "Please provide your high school below.": "Lynbrook High School"
                        expect(page).to have_checked_field "registration_bus_true"
                      end
                    end

                    describe "User clicks Continue on Camper Roles page" do
                      background do
                        check "Night Market"
                        check "Bus Monitor"
                        click_button "Continue"
                      end

                      it "continues to Waiver page" do
                        expect(page).to have_text "Waiver"
                      end

                      describe "User clicks Back on Waiver page" do
                        background { click_link "Back" }

                        it "returns to Camper Roles page with boxes checked" do
                          expect_no_error_messages
                          expect(page).to have_text "Camper Involvement"
                          expect(page).to have_checked_field "Night Market"
                          expect(page).to have_checked_field "Bus Monitor"
                          expect(page).to have_no_checked_field "Family Activity"
                          expect(page).to have_no_checked_field "Clinic"
                          expect(page).to have_no_checked_field "Large Group Icebreaker"
                        end
                      end

                      describe "User clicks Continue on Waiver page" do
                        context "when waiver signature and date are blank" do
                          background { click_button "Continue" }

                          it "re-renders the page with an error message" do
                            expect(page).to have_text "Waiver"
                            expect(page).to have_text "5 errors occurred"
                            # TODO: fix error messages on this page
                          end
                        end

                        context "when waiver signature and date are valid" do
                          background do
                            fill_form "registration_additional_notes": "Group request: Kevin Chan",
                                      "Parent/Guardian Signature": "Jonathan Chen"
                            select Date::MONTHNAMES[Date.today.month], from: "registration_waiver_month"
                            select Date.today.day, from: "registration_waiver_day"
                            select Date.today.year, from: "registration_waiver_year"
                            click_button "Continue"
                          end

                          it "continues to Review page" do
                            expect(page).to have_text "Review Camper Details"
                          end

                          describe "user clicks Back on Review page" do
                            background { click_link "Back" }

                            it "returns to Waiver page with fields filled" do
                              expect_no_error_messages
                              expect(page).to have_text "Waiver"
                              expect_filled_fields "registration_additional_notes": "Group request: Kevin Chan",
                                                   "Parent/Guardian Signature": "Jonathan Chen"
                              expect(page).to have_select "registration_waiver_month",selected: Date::MONTHNAMES[Date.today.month]
                              expect(page).to have_select "registration_waiver_day"#, selected: Date.today.day
                              expect(page).to have_select "registration_waiver_year"#, selected: Date.today.year
                              # TODO: check waiver date selected correctly
                            end
                          end

                          describe "User clicks Continue on Review page" do
                            background { click_button "Continue" }

                            it "continues to Sibling page" do
                              expect_no_error_messages
                              expect(page).to have_text "Would you like to register a sibling?"
                              expect(page).to have_no_link "Back"
                            end

                            describe "User clicks Continue on Sibling page" do
                              context "when they are registering a sibling" do
                                background do
                                  choose "Add registration for a sibling"
                                  click_button "Continue"
                                end

                                it "returns to blank Camper page" do
                                  expect_no_error_messages
                                  expect(page).to have_text "Camper First Name"
                                end
                              end

                              context "when they are not registering siblings" do
                                background do
                                  choose "Continue without registering any additional siblings"
                                  click_button "Continue"
                                end

                                it "continues to Donation page" do
                                  expect_no_error_messages
                                  expect(page).to have_text "Add A Donation"
                                end

                                describe "user clicks Back on Donation page" do
                                  background { click_link "Back" }

                                  it "returns to Add A Sibling page" do
                                    expect_no_error_messages
                                    expect(page).to have_text "Would you like to register a sibling?"
                                  end
                                end

                                describe "User clicks Continue on Donation page" do
                                  background do
                                    choose "Other"
                                    fill_in "registration_payment_donation_amount", with: "123"
                                    click_button "Continue"
                                  end

                                  it "continues to Payment page" do
                                    expect_no_error_messages
                                    expect(page).to have_text "Payment Summary"
                                  end

                                  describe "User clicks Back on Payment page" do
                                    background { click_link "Back" }

                                    context "when Other donation amount is specified" do
                                      it "returns to Donation page with amount specified in field" do
                                        expect_no_error_messages
                                        expect(page).to have_text "Add A Donation"
                                        expect(page).to have_checked_field "Other"
                                        expect(page).to have_field "registration_payment_donation_amount", with: "123"
                                      end
                                    end

                                    context "when pre-defined amount is specified" do
                                      background do
                                        choose "25"
                                        click_button "Continue"
                                        click_link "Back"
                                      end

                                      it "returns to Donation page with option selected" do
                                        expect_no_error_messages
                                        expect(page).to have_text "Add A Donation"
                                        expect(page).to have_checked_field "25"
                                      end
                                    end
                                  end

                                  # describe "User enters payment information and submits form" do
                                  #   context "with valid payment information" do
                                  #     background do
                                  #       StripeMock.start_client
                                  #       fill_form "Credit/Debit Card Number": "4242424242424242",
                                  #                 "CVC": "123",
                                  #                 "Billing Zip": "12345"
                                  #       select "12", from: "card_exp_month"
                                  #       select "2032", from: "card_exp_year"
                                  #       click_button "Submit Payment & Complete Registration"
                                  #     end

                                  #     it "succesfully submits registration and shows confirmation page" do
                                  #       expect_no_error_messages
                                  #       expect(page).to have_text "Thank you for registering for LYF Camp"
                                  #       StripeMock.stop_client
                                  #     end
                                  #   end

                                  #   context "width invalid payment information" do
                                  #     background do
                                  #       StripeMock.start_client
                                  #       fill_form "Credit/Debit Card Number": "4000000000000010",
                                  #                 "CVC": "123",
                                  #                 "Billing Zip": "12345"
                                  #       select "12", from: "card_exp_month"
                                  #       select "2032", from: "card_exp_year"
                                  #       click_button "Submit Payment & Complete Registration"
                                  #     end

                                  #     it "re-renders the page with error messages" do
                                  #       expect(page).to have_text "Payment Summary"
                                  #       expect(page).to have_text "Error"
                                  #       StripeMock.stop_client
                                  #     end
                                  #   end
                                  # end # describe "User enters payment information and submits form"

                                end # describe "User clicks Continue on Donation page"
                              end # context "when they are not registering siblings"
                            end # describe "User clicks Continue on Sibling page"
                          end # describe "User clicks Continue on Review page"
                        end # context "when waiver signature and date are valid"
                      end # describe "User clicks Continue on Waiver page"
                    end # describe "User clicks Continue on Camper Roles page"
                  end # context "when registration detail fields are valid"
                end # describe "User clicks Continue on Details page"
              end # context "when camper field values are valid"
            end # describe "User clicks Continue on Camper page"
          end # describe "User clicks Continue on Referral page"
        end # context "when parent field values are valid"
      end # describe "User clicks Continue on Parent page"
    end # describe "User clicks "Get Started" button"
  end # describe "User visits registration page"
end
