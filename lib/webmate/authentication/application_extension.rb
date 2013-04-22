module Webmate
  module Authentication
    module ApplicationExtension
      def self.included(base)
        base.class_eval do
          alias_method :authorized_by_ancestors?, :authorized_to_open_connection?
          remove_method :authorized_to_open_connection?
        end
      end

      def authorized_to_open_connection?(scope)
        authorized_by_ancestors? && Webmate::Authentication::Token.new(request, scope).valid?
      end
    end
  end
end
