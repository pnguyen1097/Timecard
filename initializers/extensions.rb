module Initializers
  module Extensions
    def self.included(base)
      base.class_eval do
        puts "Register Sinatra extensions and helpers"
        register Sinatra::Namespace
        register Sinatra::MultiRoute
        helpers Sinatra::ContentFor
      end

    end
  end
end
