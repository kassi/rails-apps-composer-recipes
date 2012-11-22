gem 'rails-i18n'
gem 'rails-i18n-debug', :group => :development

if prefer :authentication, 'devise'
  gem 'devise-i18n'
  gem 'devise-i18n-views'
end

before_config do
  # Code here is run before any configuration prompts.
end

after_bundler do
end

after_everything do
  # This block is run after the 'after_bundler' block.
  # Use this section to finalize the application.
  # Run database migrations or make a final git commit.

end

# A recipe has two parts: the Ruby code and YAML matter that comes
# after a blank line with the __END__ keyword.

__END__

name: i18n
description: "Adding i18n to the rails app"
author: kassi

requires: [gems]
run_after: [gems, init, prelaunch]
category: other
