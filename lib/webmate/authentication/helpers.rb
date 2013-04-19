module Webmate
  module Authentication
    module Helpers
      # The main accessor to the warden middleware
      def warden
        request.env['warden']
      end

      # Check the current session is authenticated to a given scope
      def signed_in?(scope = nil)
        scope ? warden.authenticated?(scope) : warden.authenticated?
      end

      def current_user(scope = nil)
        warden.user(scope)
      end

      # Authenticate a user against defined strategies
      def authenticate(*args)
        warden.authenticate(*args)
      end
      alias_method :login, :authenticate
    end
  end
end

=begin
module Webmate
  module Authentication
    module Helpers
      # The main accessor to the warden middleware
      def warden
        request.env['warden']
      end

      # Check the current session is authenticated to a given scope
      def signed_in?(scope = nil)
        scope ? warden.authenticated?(scope) : warden.authenticated?
      end

      # Authenticate a user against defined strategies
      def authenticate(*args)
        warden.authenticate!(*args)
      end

      # Terminate the current session
      def sign_out(scopes = nil)
        scopes ? warden.logout(scopes) : warden.logout(warden.config.default_scope)
      end

      # Store the logged in user in the session
      def sign_in(new_user, opts = {})
        warden.set_user(new_user, opts)
      end

      def get_user_for_authentication(scope)
        warden.user(scope)
      end

      # Require authorization for an action
      def authenticate!(scope)
        unless authenticated?(scope)
          session[:return_to] = request.path
          redirect(configatron.authentication.failure_path)
        end
      end
    end
  end
end
=end
