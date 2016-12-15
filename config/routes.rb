Rails.application.routes.draw do
  namespace :admin do
    resources :camps
    resources :families
    resources :campers
    resources :registrations
    resources :registration_payments
    resources :referrals
    resources :referral_methods
    resources :registration_discounts

    root to: "registrations#index"
  end

  resources :registration
end
