Rails.application.routes.draw do
  get 'registration_payment/show'

  get 'registration_payment/edit'

  get 'registration_payment/update'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :donations, only: [:new], except: [:create] do
    # post "create" => "donations#create", as: :create, path: :new, on: :collection
    post 'create', to: 'donations#create', as: :create, on: :collection
  end
  get '/donations/confirm', to: 'donations#confirm', as: :donation_confirmation

  resources :last_day_purchases, path: '/lastdaypurchases', only: [:new], except: [:create] do
    # post "create" => "last_day_purchases#create", as: :create, path: :new, on: :collection
    post 'create', to: 'last_day_purchases#create', as: :create, on: :collection
  end
  get '/lastdaypurchases/confirm', to: 'last_day_purchases#confirm', as: :last_day_purchase_confirmation
  get '/lastdaypurchases', to: redirect('/lastdaypurchases/new')

  resources :registration_payments, only: [:show, :update], param: :payment_token

  devise_for :users, path: '', path_names: {sign_in: 'login', sign_out: 'logout'}

  resources :registration
end
