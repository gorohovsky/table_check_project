source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.2"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

gem "mongoid"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

gem "http"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

gem "sidekiq", "~> 7.3"

gem "sidekiq-cron"

gem "redis"

gem "dry-schema"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  gem "dotenv"

  gem "factory_bot_rails"

  gem 'faker'

  gem "pry", "~> 0.15.0"

  gem "rubocop", require: false

  gem "rspec-rails", "~> 7.0.0"
end

group :test do
  gem "vcr", "~> 6.3"

  gem "rspec-sidekiq"

  gem "webmock"
end
