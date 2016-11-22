FactoryGirl.define do
  factory :create_registration_discount do
    code "MyString"
    discount_percent 1
    redeemed false
    camp nil
    registration_payment nil
  end
end
