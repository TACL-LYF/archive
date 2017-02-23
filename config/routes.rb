Rails.application.routes.draw do
  resources :donations, only: [:new], except: [:create] do
    post "create" => "donations#create", as: :create, path: :new, on: :collection
  end
  get '/donations/confirm', to: 'donations#confirm', as: :donation_confirmation

  devise_for :users, path: '', path_names: {sign_in: 'login', sign_out: 'logout'}

  namespace :admin do
    resources :camps
    resources :families
    resources :campers
    resources :registrations
    resources :registration_payments
    resources :referrals
    resources :registration_discounts
    resources :referral_methods
    resources :donations

    root to: "registrations#index"
  end

  root to: "admin/registrations#index"
  resources :registration
end
