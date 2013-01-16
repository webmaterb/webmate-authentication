# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require 'webmate/authentication/version'

Gem::Specification.new do |gem|
  gem.name          = "webmate-authentication"
  gem.version       = Webmate::Authentication::VERSION

  gem.authors       = ["Iskander Haziev"]
  gem.email         = ["gvalmon@gmail.com"]
  gem.description   = %q{Authentication plugin for Webmate}
  gem.summary       = %q{Authentication plugin for Webmate}
  gem.homepage      = "https://github.com/webmate/webmate-authentication"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ["lib"]

  gem.add_dependency("webmate")
  gem.add_dependency("warden")
  gem.add_dependency("bcrypt-ruby")
end
