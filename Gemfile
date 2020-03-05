source 'https://rubygems.org'
ruby '~> 2.5.0'

gem 'rails',                   '5.2.4.1'
gem 'pg',                      '1.0.0'
gem 'faker',                   '1.8.7'
gem 'bootstrap-sass',          '3.4.1'
gem 'puma',                    '>= 3.12.4'
gem 'sass-rails',              '5.0.7'
gem 'uglifier',                '4.1.8'
gem 'coffee-rails',            '4.2.2'
gem 'jquery-rails',            '4.3.1'
gem 'turbolinks',              '5.1.0'
gem 'jbuilder',                '2.7.0'
gem 'wicked'
gem 'stripe'
gem 'envyable'
gem 'data-confirm-modal'
gem 'activeadmin'
gem 'activeadmin_addons'
gem 'activeadmin-xls',          '~>2.0.0'
gem 'devise'
gem 'phonelib'
gem 'client_side_validations',  '11.1.1'
gem 'exception_notification'
gem 'slack-notifier'
gem 'immutable-struct'
gem 'recipient_interceptor'
gem 'best_in_place',            '3.1.1'
# gem 'zip-zip'
# gem 'axlsx_rails'
# gem 'will_paginate',           '3.1.0'
# gem 'bootstrap-will_paginate', '0.0.10'

group :development, :test do
# gem 'sqlite3',     '1.3.11'
  gem 'byebug',      '10.0.2', platform: :mri
  gem 'rspec-rails'
  gem 'factory_bot_rails'
end

group :development do
  gem 'web-console',           '3.5.1'
  gem 'listen',                '3.1.5'
  gem 'spring',                '1.7.2'
  gem 'spring-watcher-listen', '~> 2.0'
end

group :test do
  gem 'rails-controller-testing', '1.0.2'
  gem 'minitest-reporters',       '1.2.0'
  gem 'guard',                    '2.14.2'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'stripe-ruby-mock',         '2.5.3', :require => 'stripe_mock'
  gem 'thin', '~> 1.7'
# gem 'guard-rspec'
# gem 'launchy'
end

group :production do
  gem 'newrelic_rpm'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
