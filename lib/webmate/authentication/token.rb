module Webmate::Authentication
  class Token
    attr_reader :token_info

    def initialize(request, scope)
      @request = request
      @scope = scope
    end

    # generate token & info
    # and store this to redis
    def build
      @token = SecureRandom.hex
      @expire_at = 60.minutes.from_now.utc

      @token_info = { 
        'token' => @token,
        'expire_at' => @expire_at
      }

      # update record
      redis.set(token_key, Yajl::Encoder.encode(@token_info))

      @token_info
    end

    # reset key in redis
    def expire
      return true if model.blank? # user not logged in
      redis.del(token_key)
      true
    end

    def valid?
      return false if model.blank? # user not logged in with current scope.
      value = redis.get(token_key)

      return false if value.blank?
      token_info = Yajl::Parser.parse(value)

      token = @request.params["token"]
      token_info['token'] == token && Time.parse(token_info['expire_at']).utc > Time.now.utc
    end

    private

    # TODO: use configatron values
    def redis
      @redis = Redis.new
    end

    # return place, where will be store auth token for this object
    # don't use bcrypt - its very slooow ~ 0.1 sec for generating
    def token_key
      Digest::MD5.hexdigest("smth-unique-#{model.class.to_s.downcase}-#{model.id}-key")
    end

    def model
      @model ||= warden.user(@scope)
    end

    def warden
      @request.env['warden']
    end
  end
end
