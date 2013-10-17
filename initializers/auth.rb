module Initializers
  module Auth
    def self.included(base)
      base.class_eval do

        # Rack stuff
        use Rack::Session::Pool
        use OmniAuth::Builder do
          provider :open_id,
            :store => OpenID::Store::Memory.new,
            :name => :google,
            :identifier => 'https://www.google.com/accounts/o8/id'

          provider :open_id,
            :store => OpenID::Store::Memory.new,
            :name => :yahoo,
            :identifier => 'http://yahoo.com'

          provider :open_id,
            :store => OpenID::Store::Memory.new

          provider :identity,
            :fields => [:username, :name],
            :locate_conditions => lambda {
              { :username => req['auth_key'] }
            },
            :on_failed_registration => Proc.new { |env|
              error = env['omniauth.identity'].errors.to_hash
              params = ''
              error.keys.each do |key|
                params += "&#{key}="
                params += error[key][0].gsub(/ /,"%20").gsub(/"/,"%22")
              end
              resp = Rack::Response.new("", 302)
              resp.redirect("/register?" + params)
              resp.finish
            }
        end

        OmniAuth.config.on_failure = Proc.new { |env|
          OmniAuth::FailureEndpoint.new(env).redirect_to_failure
        }
      end

    end
  end
end
