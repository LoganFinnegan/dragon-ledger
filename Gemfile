source "https://rubygems.org"
gem "rails", "~> 7.2.2", ">= 7.2.2.2"
gem "sprockets-rails"
gem "pg", "~> 1.6"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "faraday"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri mingw mswin x64_mingw jruby ], require: "debug/prelude"
  gem "rspec-rails"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webmock"
end
