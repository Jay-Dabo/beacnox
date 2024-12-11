class Beacnox::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)
  desc "Generates initial config for beacnox gem"

  def copy_initializer_file
    copy_file "initializer.rb", "config/initializers/beacnox.rb"
  end
end
