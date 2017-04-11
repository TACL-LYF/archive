Rails.configuration.stripe = {
  :publishable_key => Rails.application.secrets.stripe_publishable_key,
  :secret_key      => Rails.application.secrets.stripe_secret_key
}

Stripe.api_key = Rails.application.secrets.stripe_secret_key
STRIPE_PUBLIC_KEY = Rails.application.secrets.stripe_publishable_key

unless defined? STRIPE_JS_HOST
  STRIPE_JS_HOST = 'https://js.stripe.com'
end
