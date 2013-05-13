module Webmate
  module Authentication
    module Helpers
      module View
        # we should define way to access warden
        # 
        # and we should define scope method
        def current_user
          @responder.request.env['warden'].user('user')
        end 

        def current_user_id
          @responder.request.env['warden'].user('user').id
        end

        def warden
        end

        def scope
        end
      end
    end
  end
end
