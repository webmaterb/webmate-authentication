module Webmate
  module Authentication
    module Strategies
      class Password < Warden::Strategies::Base
        attr_accessor :scope

        def resource_class
          User
        end

        def valid?
          username || password
        end

        def authenticate!
          user = resource_class.authenticate(username, password)
          user.nil? ? fail!("Could not log in") : success!(user)
        end

        def username
          params[scope.to_s]["email"]
        end

        def password
          params[scope.to_s]["password"]
        end

        class << self
          def find(scope, id)
            new({}, scope).resource_class.find(id)
          end
        end
      end
    end
  end
end