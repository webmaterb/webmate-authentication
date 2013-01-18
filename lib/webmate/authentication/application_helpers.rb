module Webmate
  module Authentication
    module ApplicationHelpers
      def authentication_for(scope)
        Warden::Manager.serialize_into_session(scope) { |user| user.nil? ? nil : user._id }
        Warden::Manager.serialize_from_session(scope) { |id| id.nil? ? nil : Strategies::Password.find(scope, id) }
        [self, Webmate::Responders::Base].each do |klass|
          klass.class_eval <<-METHODS, __FILE__, __LINE__ + 1
            def authenticate_#{scope}!
              authenticate!(:#{scope})
            end

            def #{scope}_signed_in?
              signed_in?(:#{scope})
            end

            def current_#{scope}
              @current_#{scope} ||= get_user_for_authentication(:#{scope})
            end

            def #{scope}_websocket_token
              if #{scope}_signed_in?
                current_#{scope}.websocket_token_with_id
              else
                ""
              end
            end
          METHODS
        end
        resource_name = scope.to_s
        resource_class = resource_name.classify.constantize
        collection_name = scope.to_s.pluralize

        locals = {
          resource_name: resource_name,
          collection_name: collection_name,
          resource_class: resource_class
        }

        get "/#{collection_name}/sign_in" do
          resource = resource_class.new
          locals[:resource] = resource
          slim :'/sessions/new', locals: locals
        end

        post "/#{collection_name}/sign_in" do
          authenticate(scope: scope)
          redirect session[:return_to] ? session.delete(:return_to) : configatron.authentication.success_path
        end

        get "/#{collection_name}/sign_out" do
          authenticate(scope: scope)
          sign_out(scope)
          redirect configatron.authentication.logout_path
        end

        post "/#{collection_name}/unauthenticated" do
          redirect configatron.authentication.failure_path
        end

        get "/#{collection_name}/sign_up" do
          user = resource_class.new
          slim :"registrations/new", locals: {user: user}
        end

        post '/users/sign_up' do
          user = resource_class.new(params[resource_name])
          if user.save
            redirect '/'
          else
            slim :"registrations/new"
          end
        end
      end

      def self.registered(app)
        app.register Warden
        app.helpers Webmate::Authentication::Helpers

        unless Warden && Warden::Manager
          raise "WardenPlugin::Error - Install warden with 'gem install warden' to use plugin!"
        end
        app.use Warden::Manager do |manager|
          manager.default_strategies :password
          manager.default_scope = :user
          manager.failure_app = app
        end
        Warden::Manager.before_failure { |env, opts|
          env['REQUEST_METHOD'] = "POST"
          env['PATH_INFO'] = "/#{opts[:scope].to_s.pluralize}/unauthenticated"
        }
        Warden::Strategies.add(:password, Webmate::Authentication::Strategies::Password)
      end
    end
  end
end