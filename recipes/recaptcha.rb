prefs[:recaptcha] = true unless prefs.has_key? :recaptcha

gem "recaptcha", :require => "recaptcha/rails"

before_config do
  # Code here is run before any configuration prompts.
end

after_bundler do
  repo = 'https://raw.github.com/kassi/rails-apps-composer-recipes/master/templates/recaptcha/'

  copy_from_repo 'config/initializers/recaptcha.rb', :repo => repo

  if prefer :authentication, 'devise'
    copy_from_repo 'app/controllers/registrations_controller.rb', :repo => repo

    inject_into_file 'config/routes.rb', ", controllers: { registrations: 'registrations' }", :after => 'devise_for :users'

    inject_into_file 'app/views/devise/registrations/new.html.erb', :before => '  <%= f.button :submit' do <<-RUBY
  <%= f.label 'Security check', :required => true %>
  <%= recaptcha_tags :display => { :theme => 'blackglass' } %><br />
RUBY
    end
  end
end

after_everything do
  # This block is run after the 'after_bundler' block.
  # Use this section to finalize the application.
  # Run database migrations or make a final git commit.

  ### GIT ###
  if prefer :git, true
    git :add => '-A'
    git :commit => '-qm "rails_apps_composer: add recaptcha"'
  end
end

# A recipe has two parts: the Ruby code and YAML matter that comes
# after a blank line with the __END__ keyword.

__END__

name: recaptcha
description: "Adding recaptcha to devise sign up"
author: kassi

requires: [gems]
run_after: [gems, init, prelaunch]
category: other
