module Webmate
  module Authentication
    module Strategies
      class Password < Warden::Strategies::Base
        attr_accessor :scope

        def authenticate!
          user = resource_class.authenticate(username, password)
          user.nil? ? fail!("Could not log in") : success!(user)
        end

        def valid?
          username.present? && password.present?
        end

        def self.find(scope, id)
          new({}, scope).resource_class.find(id)
        end

        private

        def resource_class
          scope.to_s.classify.constantize
        end

        def username
          params[scope.to_s]["email"]
        end

        def password
          params[scope.to_s]["password"]
        end
      end
    end
  end
end
