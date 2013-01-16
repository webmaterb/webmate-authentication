require 'bcrypt'
module Webmate
  module Authentication
    module Model
      extend ActiveSupport::Concern

      PASSWORD_SALT = "webmate"
      WEBSOCKET_TOKEN_SALT = "webmate"

      included do
        field :email
        field :encrypted_password
        field :websocket_token

        validates :email, presence: true, uniqueness: true
        validates :encrypted_password, presence: true, confirmation: true
        attr_reader :password

        before_create :generate_websocket_token
      end

      def password=(password)
        @password = password
        self.encrypted_password = BCrypt::Password.create("#{password}#{PASSWORD_SALT}")
      end

      def websocket_token_encrypted
        Digest::MD5.hexdigest(websocket_token_hash)
      end

      def websocket_token_with_id
        "#{_id}:#{websocket_token_encrypted}"
      end

      def websocket_token_hash
        date = Date.today.to_datetime.to_i
        "#{websocket_token}#{date}"
      end

      def generate_websocket_token
        self.websocket_token = Digest::MD5.hexdigest("#{email}--#{Time.now.to_i}")
      end

      module ClassMethods
        def authenticate(email, password)
          user = where(email: email).first
          return unless user
          auth = BCrypt::Password.new(user.encrypted_password) == "#{password}#{PASSWORD_SALT}"
          auth ? user : nil
        rescue BCrypt::Errors::InvalidHash
          nil
        end

        def authenticate_websocket(token_with_id)
          user_id, token = token_with_id.to_s.split(':')
          user = find(user_id)
          return unless user
          auth = token == Digest::MD5.hexdigest(user.websocket_token_hash)
          auth ? user : nil
        rescue BCrypt::Errors::InvalidHash
          nil
        end
      end
    end
  end
end