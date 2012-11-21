before_config do
  # Code here is run before any configuration prompts.
end

after_bundler do
  # Code here is run after Bundler installs all the gems for the project.
  # Use this section to run generators and rake tasks.
  # Download any files from a repository for models, controllers, views, and routes.
  if prefer :bootstrap, 'less'
    append_to_file 'app/assets/stylesheets/bootstrap_and_overrides.css.less', "@import 'variables.less';\n"
    create_file 'app/assets/stylesheets/variables.less', <<-RUBY
// Add variables for styling twitter bootstrap to this file.
// You can use one of the following nice resources:
//
//     - http://www.boottheme.com/#generatetheme
//
RUBY
    ### GIT ###
    git :add => '-A' if prefer :git, true
    git :commit => '-qm "rails_apps_composer: add bootstrap variables"' if prefer :git, true
  end
end

after_everything do
  # This block is run after the 'after_bundler' block.
  # Use this section to finalize the application.
  # Run database migrations or make a final git commit.

end

# A recipe has two parts: the Ruby code and YAML matter that comes
# after a blank line with the __END__ keyword.

__END__

name: bootvars
description: "Adding variables.less to the project"
author: kassi

category: frontend
requires: [frontend]
run_after: [frontend]
args: -T
