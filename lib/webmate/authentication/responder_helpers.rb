module Webmate
  module Authentication
    module Helpers
      module ResponderHelpers
        # The main accessor to the warden middleware
        def warden
          request.env['warden']
        end

        # Check the current session is authenticated to a given scope
        def signed_in?(scope = nil)
          scope ? warden.authenticated?(scope) : warden.authenticated?
        end

        def current_user_id(scope = :user)
          @current_user_id ||= warden.user(scope).try(:id)
        end

        # there are should be no way to change in-session object
        def current_user(scope = :user)
          @current_user ||= begin
            user = warden.user(scope)
            user.present? ? user.class.find(user.id) : nil
          end
        end

        # Authenticate a user against defined strategies
        def authenticate(*args)
          warden.authenticate(*args)
        end

        alias_method :login, :authenticate
      end
    end
  end
end
