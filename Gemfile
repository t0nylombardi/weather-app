# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "~> 8.0.2", ">= 8.0.2.1"
gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "view_component"
gem "httparty"
gem "jbuilder"

# gem "bcrypt", "~> 3.1.7"

gem "tzinfo-data", platforms: %i[windows jruby]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

group :development do
  gem "annotaterb"
  gem "web-console"
  gem "rubocop-rake"
  gem "rubocop-rspec"
  gem "rubocop-thread_safety"
  gem "ruby_audit"
  gem "ruby-lsp-rspec"
  gem "standard"
  gem "standard-rails"
end

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "irb"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 8.0", ">= 8.0.2"
  gem "shoulda-matchers"
end
