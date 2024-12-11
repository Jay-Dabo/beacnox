$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "beacnox/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = "beacnox"
  spec.version = Beacnox::VERSION
  spec.authors = ["Jeffrey Dabo"]
  spec.email = ["jeffrey.dabo@purplewave.com"]

  spec.summary = "Simple Beacnox monitor. Alternative to the NewRelic, Datadog or other services."
  spec.description = "3rd party dependency-free solution how to monitor performance of your Rails applications."
  spec.homepage = "https://github.com/Jay-Dabo/beacnox"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Jay-Dabo/beacnox"
  spec.metadata["changelog_uri"] = "https://github.com/Jay-Dabo/beacnox/blob/main/CHANGELOG.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "railties"
  spec.add_dependency "redis"
  spec.add_dependency "browser"

  spec.add_development_dependency "activestorage"
  spec.add_development_dependency "actionmailer"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "grape"
  spec.add_development_dependency "sidekiq"
  spec.add_development_dependency "mimemagic"
  spec.add_development_dependency "delayed_job_active_record"
  spec.add_development_dependency "daemons"
  spec.add_development_dependency "wrapped_print"
  spec.add_development_dependency "puma"
  spec.add_development_dependency "sprockets-rails"
  spec.add_development_dependency "standardrb"

  spec.add_development_dependency "sys-filesystem"
  spec.add_development_dependency "sys-cpu"
  spec.add_development_dependency "get_process_mem"
end
