FactoryGirl.define do
  factory :donation do
    name "MyString"
    email "MyString"
    phone "MyString"
    street "MyString"
    suite "MyString"
    state "MyString"
    zip "MyString"
    amount "9.99"
    stripe_charge_id "MyString"
    stripe_brand "MyString"
    stripe_last_four 1
  end
end
