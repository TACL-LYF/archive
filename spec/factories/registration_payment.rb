require 'faker'

FactoryBot.define do
  factory :registration_payment do
    reg_step { "donation" }
    transient do
      registrations_count { 1 }
    end

    factory :registration_payment_for_multiple_registrations do
      transient do
        registrations_count { 2 }
      end
    end

    after(:build) do |reg_payment, evaluator|
      camp = build(:camp, year: 2107)
      reg_payment.registrations = create_list(:registration,
                                             evaluator.registrations_count,
                                             registration_payment: reg_payment,
                                             camp: camp)
      reg_payment.calculate_total
    end
  end
end
