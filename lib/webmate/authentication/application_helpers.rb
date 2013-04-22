module Webmate
  module Authentication
    module ApplicationHelpers
      def self.registered(app)
        app.register Warden
        app.helpers Webmate::Authentication::Helpers
        app.set :sessions, true

        unless Warden && Warden::Manager
          raise "WardenPlugin::Error - Install warden with 'gem install warden' to use plugin!"
        end

        app.use Warden::Manager do |manager|
          manager.default_strategies :password
          manager.default_scope = :user
          manager.failure_app = app
          # required - socket.io requires 401 if user not authorized
          # and this case shouldn't be processed by warden
          manager.intercept_401 = false
        end

        Warden::Manager.before_failure { |env, opts|
          env['REQUEST_METHOD'] = "POST"
          env['PATH_INFO'] = "/#{opts[:scope].to_s.pluralize}/unauthenticated"
        }

        Warden::Strategies.add(:password, Webmate::Authentication::Strategies::Password)
      end
    end
  end
end
