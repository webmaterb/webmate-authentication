require 'warden'
require 'webmate/application'
require 'webmate/responders/base'
require 'webmate/authentication/helpers'
require 'webmate/authentication/application_helpers'
require 'webmate/authentication/responder_helpers'
require 'webmate/authentication/model'
require 'webmate/authentication/config'
require 'webmate/authentication/strategies/password'

Webmate::Application.register Webmate::Authentication::ApplicationHelpers
Webmate::Responders::Base.send :include, Webmate::Authentication::ResponderHelpers