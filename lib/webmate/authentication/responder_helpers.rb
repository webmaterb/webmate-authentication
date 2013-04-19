module Webmate
  module Authentication
    module ResponderHelpers
      include Helpers
    end
  end
end

module Webmate
  module Authentication
=begin
    module ResponderHelpers
      include Helpers
      # The main accessor to the warden middleware
      def warden
        request.env['warden']
      end

      # Check the current session is authenticated to a given scope
      alias_method :_signed_in?, :signed_in?
      def signed_in?(scope = nil)
        if request.websocket?
          "current_#{scope}".present?
        else
          _signed_in?(scope)
        end
      end

      # Authenticate a user against defined strategies
      alias_method :_authenticate, :authenticate
      def authenticate(*args)
        if request.websocket?
          puts "this action is not allowed for websockets"
        else
          _authenticate(*args)
        end
      end

      # Terminate the current session
      alias_method :_sign_out, :sign_out
      def sign_out(scopes = nil)
        if request.websocket?
          puts "this action is not allowed for websockets"
        else
          _sign_out(scopes)
        end
      end

      # Store the logged in user in the session
      alias_method :_sign_in, :sign_in
      def sign_in(new_user, opts = {})
        if request.websocket?
          puts "this action is not allowed for websockets"
        else
          _sign_in(new_user, opts)
        end
      end

      alias_method :_get_user_for_authentication, :get_user_for_authentication
      def get_user_for_authentication(scope)
        if request.websocket?
          token = params[:"#{scope}_websocket_token"]
          User.authenticate_websocket(token)
        else
          _get_user_for_authentication(scope)
        end
      end

      # Require authorization for an action
      alias_method :_authenticate!, :authenticate!
      def authenticate!(scope)
        if request.websocket?
          puts "this action is not allowed for websockets"
        else
          _authenticate!(scope)
        end
      end
    end
=end
  end
end
