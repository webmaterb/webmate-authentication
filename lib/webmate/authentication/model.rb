require 'bcrypt'
module Webmate
  module Authentication
    module Model
      extend ActiveSupport::Concern

      PASSWORD_SALT = "webmate"

      included do
        field :email
        field :encrypted_password

        validates :email, presence: true, uniqueness: true
        validates :encrypted_password, presence: true, confirmation: true

        attr_reader :password
      end

      def password=(password)
        @password = password
        self.encrypted_password = BCrypt::Password.create("#{password}#{PASSWORD_SALT}")
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
      end
    end
  end
end
