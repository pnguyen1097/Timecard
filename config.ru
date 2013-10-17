require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'sinatra/multi_route'

require './app'
run App
