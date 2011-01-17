require 'rubygems'

Gem::Specification.new do |s|
  s.name = %q{sinatra-mobile-adsense}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["milk1000cc", "munshkr"]
  s.date = %q{2011-01-15}
  s.description = %q{Sinatra extension that provides a helper for showing Google Adsense for Mobile.}
  s.email = %q{munshkr@gmail.com}
  s.extra_rdoc_files = [
    "MIT-LICENSE",
    "README.md"
  ]
  s.files = Dir[
    "MIT-LICENSE",
    "README.md",
    "Rakefile",
    "lib/**/*"
    "spec/**/*"
  ]
  s.has_rdoc = false
  s.homepage = %q{http://github.com/munshkr/sinatra-mobile-adsense}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.summary = %q{Sinatra extension that provides a helper for showing Google Adsense for Mobile.}
  s.test_files = Dir['spec/**/spec_*.rb']
end
