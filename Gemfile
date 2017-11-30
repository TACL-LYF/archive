source 'https://rubygems.org'
ruby '2.3.0'

gem 'rails',                   '5.0.0.1'
gem 'pg',                      '0.18.4'
gem 'faker',                   '1.6.3'
gem 'bootstrap-sass',          '3.3.6'
gem 'puma',                    '3.4.0'
gem 'sass-rails',              '5.0.6'
gem 'uglifier',                '3.0.0'
gem 'coffee-rails',            '4.2.1'
gem 'jquery-rails', '~> 4.2', '>= 4.2.2'
gem 'turbolinks',              '5.0.1'
gem 'jbuilder',                '2.4.1'
gem 'wicked'
gem 'stripe'
gem 'envyable'
gem 'data-confirm-modal'
gem 'activeadmin'
gem 'activeadmin_addons'
gem 'devise'
gem 'phonelib'
gem 'client_side_validations', '~> 8.0', '>= 8.0.1'
gem 'exception_notification'
gem 'slack-notifier'
gem 'axlsx_rails'
gem 'immutable-struct'
gem 'recipient_interceptor'
# gem 'will_paginate',           '3.1.0'
# gem 'bootstrap-will_paginate', '0.0.10'

group :development, :test do
# gem 'sqlite3',     '1.3.11'
  gem 'byebug',      '9.0.0', platform: :mri
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :development do
  gem 'web-console',           '3.1.1'
  gem 'listen',                '3.0.8'
  gem 'spring',                '1.7.2'
  gem 'spring-watcher-listen', '2.0.0'
end

group :test do
  gem 'rails-controller-testing', '0.1.1'
  gem 'minitest-reporters',       '1.1.9'
  gem 'guard',                    '2.13.0'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'stripe-ruby-mock', '~> 2.4.0', :require => 'stripe_mock'
  gem 'thin', '~> 1.7'
# gem 'guard-rspec'
# gem 'launchy'
end

group :production do
  gem 'newrelic_rpm'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
