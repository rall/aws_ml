require 'bundler'
Bundler.require(:default)

set :public_dir, "./public"

require './app'
run DigitizerApp
