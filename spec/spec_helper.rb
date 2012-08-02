require 'sinatra'
require 'rack/test'
require 'rspec'
require 'capybara/rspec'
require_relative '../app.rb'

set :environment, :test
Capybara.app = App

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
