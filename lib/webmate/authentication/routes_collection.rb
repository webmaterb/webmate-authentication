module Webmate
  module Authentication
    module RoutesCollection
      class Builder
        ALL_ROUTES = [:token, :sign_in, :sign_out]

        def initialize(scope)
          @scope = scope.to_s.pluralize
        end

        def get(options = {})
          enabled_methods = (options[:only] || ALL_ROUTES).map(&:to_sym)

          default_route_options = {
            transport: ['HTTP'],
            static_params: { scope: @scope.to_s.singularize },
            responder: Webmate::Authentication::AuthResponder,
          }

          ALL_ROUTES.each_with_object([]) do |action, routes|
            if enabled_methods.include?(action)
              routes << default_route_options.merge(get_route_params_for(action, options[action]))
            end
          end
        end
        
        private

        # return hash with
        #   method
        #   path
        def get_route_params_for(action, path = nil)
          {
            action: action,
            path: path.present? ? "/#{@scope}/#{path}" : path_for(action),
            method: method_for(action)
          }
        end

        def path_for(action)
          case action
          when :token
            "/#{@scope}/sessions/token"
          when :sign_in
            "/#{@scope}/sessions"
          when :sign_out
            "/#{@scope}/sessions"
          else
            "/#{@scope}"
          end
        end

        def method_for(action)
          case action.to_sym
          when :sign_out
            'DELETE'
          when :token
            'GET'
          else
            'POST'
          end
        end
      end

      module InstanceMethods
        # additional method to define
        # routes for authorization scope 
        #   scope = [ user, admin, etc ]
        #   options = 
        #     only: any combination from [:sign_in, :sign_out, :token]
        #     other keys specify custom paths for following actions
        #       :token    - GET   # receive auth token
        #       :sign_in  - POST
        #       :sign_out - DELETE
        #
        def authorization_for(scope, options = {})
          routes_params = Webmate::Authentication::RoutesCollection::Builder.new(scope).get(options)
          routes_params.each do |route_params| 
            add_route(Webmate::Route.new(route_params))
          end

          # TODO
          # responders/views should have methods
          # define current_#{scope} and current_#{scope}_id for BaseResponder
          self.class.send(:define_method, "current_#{scope.to_s}_id") { @responder }
        end
      end
    end
  end
end
