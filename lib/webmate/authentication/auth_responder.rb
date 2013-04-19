module Webmate::Authentication
  class AuthResponder < Webmate::Responders::Base
    include ResponderHelpers

    def sign_in
      authenticate(params.merge(scope: scope))

      respond_with current_user.to_json
    end

    def token
      if signed_in?
        token_info = generate_auth_token
      else
        token_info = {}
      end

      Yajl::Encoder.encode(token_info)
    end

    def sign_out
      expire_user_auth_token
      warden.logout(scope)

      {}
    end

    def register
      puts "Implement user creation"
      puts params.inspect
    end

    private

    # use static params from route
    def scope
      params[:scope]
    end

    def generate_auth_token
      token_info = {
        'token' => SecureRandom.hex,
        'expire_at' => 15.minutes.from_now.utc
      }

      # update record
      redis.set(redis_key, Yajl::Encoder.encode(token_info))

      token_info
    end

    def expire_user_auth_token
      redis.del(redis_key)
    end

    def token_valid?(token)
      if value = redis.get(redis_key)
        token_info = Yajl::Parser.parse(value)
        token_info['token'] == token && Time.parse(token_info['expires_at']).utc > Time.now.utc
      else
        false
      end
    end

    def redis_key
      current_user.token_key
    end

    def redis
      @redis ||= EM::Hiredis.connect
    end 
  end
end
