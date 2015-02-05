source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
gem 'mysql2', '0.3.13'

# Use SCSS for stylesheets
gem 'sass-rails'

# Bootstrap include
gem 'bootstrap-sass', '~> 3.3'
gem 'autoprefixer-rails' # Recommended by bootstrap-sass

# Gem for nice multi-select widget
gem 'bootstrap-multiselect-rails'

# Pretty printing
gem 'coderay'

# Progress bar for rake tasks
gem 'ruby-progressbar'

# For generating random, fake data
gem 'random-word'
gem 'faker'

# File uploads
gem 'jquery.fileupload-rails'

# Mime Type detection
gem 'mime-types'

# Multithreaded tasks
gem 'thread'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', '>= 0.12.1',  platforms: :ruby
gem 'libv8', '>= 3.16.14.7' # Min version for compiling on Mac OS 10.10

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Also use underscore JavaScript library
gem 'underscore-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby'

# Use Capistrano for deployment
gem 'capistrano', '~> 2.12.0', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# Pagination Is Great
gem 'kaminari'

# For building and parsing XML
gem 'nokogiri', '~> 1.6.3'
gem 'equivalent-xml'

# For authentication
gem 'devise', '>= 3.4.1'

# CUL Fedora Dependencies and Content Models
gem 'cul_scv_hydra', '>= 0.21.5'
#gem 'cul_scv_hydra', :github => 'cul/cul_scv_hydra'
#gem 'cul_scv_hydra', :path => '../cul_scv_hydra'
gem 'jettywrapper', '>= 1.5.1'

# CUL active_fedora rels-int fixes
gem 'active_fedora_relsint', :git=>'git://github.com/cul/active_fedora_relsint'

# URI Escaping
gem 'addressable'

# Use resque for background jobs
#gem 'resque', '~> 2.0.0.pre.1', github: 'resque/resque'
gem 'resque', '~> 1.0'

# For unique, opaque id generation
gem 'noid', '>= 0.7.1'
#gem 'noid', :git => 'git://github.com/cul/noid', :branch => 'fixed_sequences'

# Testing!
group :development, :test do
  gem 'rspec-rails', '~> 3.1'
  gem 'capybara'
  gem 'poltergeist' # For headless-browser JavaScript testing
  gem 'factory_girl_rails', '>= 4.4.1'
end


# Alternate development webserver
gem 'puma', group: :development
#gem 'thin', group: :development
#gem 'unicorn', group: :development
