Rails.application.routes.draw do
  resources :donations, only: [:new, :create, :confirm]

  devise_for :users, path: '', path_names: {sign_in: 'login', sign_out: 'logout'}

  namespace :admin do
    resources :camps
    resources :families
    resources :campers
    resources :registrations
    resources :registration_payments
    resources :referrals
    resources :referral_methods
    resources :registration_discounts
    resources :donations

    root to: "registrations#index"
  end

  root to: "admin/registrations#index"
  resources :registration
end
