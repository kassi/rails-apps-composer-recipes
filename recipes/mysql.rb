before_config do
  # Code here is run before any configuration prompts.
end

# add gems here
gsub_file 'Gemfile', /(gem 'sqlite3')/m do |match|
  "#{match}, :group => [:development, :test]"
end
gem 'mysql2'

after_bundler do
  # Code here is run after Bundler installs all the gems for the project.
  # Use this section to run generators and rake tasks.
  # Download any files from a repository for models, controllers, views, and routes.

  gsub_file 'config/database.yml', /production:.*\Z/m do <<-RUBY
production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name.parameterize('_')}_production
  pool: 5
  username: root
  password:
  host: localhost
RUBY
  end
end

after_everything do
  # This block is run after the 'after_bundler' block.
  # Use this section to finalize the application.
  # Run database migrations or make a final git commit.

  ### GIT ###
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: add mysql database setup"' if prefer :git, true
end

# A recipe has two parts: the Ruby code and YAML matter that comes
# after a blank line with the __END__ keyword.

__END__

name: mysql
description: "Adds mysql support for production database only"
author: kassi

requires: [setup]
run_after: [setup,git,gems]
category: configuration
