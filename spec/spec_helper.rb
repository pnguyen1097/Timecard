require 'sinatra'
require 'rack/test'
require 'rspec'
require 'capybara/rspec'
require_relative '../app.rb'

set :environment, :test
Capybara.app = App
Capybara.default_host = 'http://localhost:9292'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
