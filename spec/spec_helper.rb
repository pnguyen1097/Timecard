require 'sinatra'
require 'rack/test'
require 'rspec'
require 'json'
require 'capybara/rspec'
require 'dm-sweatshop'
require_relative '../app.rb'

set :environment, :test
use Rack::Session::Pool
Capybara.app = App
Capybara.default_host = 'http://locahost:9292'

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
  :provider => 'google',
  :uid => 'https://www.google.com/accounts/o8/id?id=AItOawm_DNI2mQM77rx6dbKe7dedUxsj-elvrHA',
  :info => {'name' => 'Phuoc Nguyen'}
})


RSpec.configure do |config|
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/test.db")
  DataMapper.finalize
  DataMapper.auto_migrate!
end
