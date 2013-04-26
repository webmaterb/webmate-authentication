require 'redis'
module Webmate::Authentication
  class AuthResponder < Webmate::Responders::Base
    include Helpers::ResponderHelpers

    def sign_in
      authenticate(params.merge(scope: scope))

      respond_with current_user.to_json(
        except: [:encrypted_password, :_id],
        methods: :id
      )
    end

    # return new token
    def token
      if signed_in?
        token_info = Webmate::Authentication::Token.new(request, scope).build
      else
        token_info = {}
      end

      Yajl::Encoder.encode(token_info)
    end

    def sign_out
      token = Webmate::Authentication::Token.new(request, scope)
      token.expire

      warden.logout(scope)
      {}
    end

    private

    # use static params from route
    def scope
      params[:scope]
    end
  end
end
