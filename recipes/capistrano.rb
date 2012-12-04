say_wizard "Configuring Capistrano"
prefs[:capistrano] = multiple_choice "Capistrano deployment?", [["Virtual Server","vserver"]] unless prefs.has_key? :capistrano
if prefer :capistrano, "vserver"
  prefs[:deploy_server] = ask_wizard "Servername to deploy to (omit www as subdomain):" unless prefs.has_key? :deploy_server
  prefs[:deploy_user]   = ask_wizard "Username to use for deployment:" unless prefs.has_key? :deploy_user
  prefs[:deploy_to]     = "/var/www/vhosts/#{prefs[:deploy_server]}/rails/#{app_name}" unless prefs.has_key? :deploy_to
end

before_config do
  # Code here is run before any configuration prompts.
end

# add gems here
gem 'capistrano'

after_bundler do
  repo = 'https://raw.github.com/kassi/rails-apps-composer-recipes/master/templates/capistrano/'
  # Code here is run after Bundler installs all the gems for the project.
  # Use this section to run generators and rake tasks.
  # Download any files from a repository for models, controllers, views, and routes.
  puts "== capify "+"="*70
  puts
  run "capify ."
  puts
  puts "="*80

  gsub_file 'Capfile', /^\s*# load 'deploy\/assets'/m, "load 'deploy/assets'"

  remove_file 'config/deploy.rb'
  create_file 'config/deploy.rb' do <<-DEPLOY.gsub /^    /, ""
    require "bundler/capistrano"

    set :bundle_flags, "--deployment --binstubs"

    set :application, "#{app_name}"
    set :repository,  "ssh://"
    # set :branch, 'master'

    set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
    # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

    set :deploy_to, "#{prefs[:deploy_to]}"
    set :user, "#{prefs[:deploy_user]}"
    set :use_sudo, false

    server "#{prefs[:deploy_server]}", :app, :web, :db, :primary => true

    # role :web, "your web-server here"                          # Your HTTP server, Apache/etc
    # role :app, "your app-server here"                          # This may be the same as your `Web` server
    # role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
    # role :db,  "your slave db-server here"

    # if you want to clean up old releases on each deploy uncomment this:
    after "deploy:restart", "deploy:cleanup"

    # if you're still using the script/reaper helper you will need
    # these http://github.com/rails/irs_process_scripts

    # If you are using Passenger mod_rails uncomment this:
    namespace :deploy do
      task :start do
        logger.info ":start task not supported by Passenger server"
      end
      task :stop do
        logger.info ":stop task not supported by Passenger server"
      end
      task :restart, :roles => :app, :except => { :no_release => true } do
        run "\#{try_sudo} touch \#{File.join(current_path,'tmp','restart.txt')}"
      end
    end

    # Skipping asset compilation when no changes occured
    # from http://www.bencurtis.com/2011/12/skipping-asset-compilation-with-capistrano/
    namespace :deploy do
      namespace :assets do
        task :precompile, :roles => :web, :except => { :no_release => true } do
          from = source.next_revision(current_revision)
          if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ lib/assets/ | wc -l").to_i > 0
            run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
          else
            logger.info "Skipping asset pre-compilation because there were no asset changes"
          end
        end
      end
    end
DEPLOY
  end

  copy_from_repo 'config/deploy/capistrano_database.rb', :repo => repo
  if prefer :mysql, true or prefer :database, 'mysql'
    copy_from_repo 'config/deploy/database.yml.erb', :repo => repo
    inject_into_file 'config/deploy.rb', :after => 'require "bundler/capistrano"' do <<-RUBY

require "./config/deploy/capistrano_database"
RUBY
    end
  end

  # add some server settings
  if prefer :authentication, 'devise'
    gsub_file 'config/initializers/devise.rb', /please-change-me-at-config-initializers-devise@example.com/, "webservice@#{prefs[:deploy_server]}"
  end
  gsub_file 'config/environments/production.rb', /config.action_mailer.delivery_method = :smtp/, "config.action_mailer.delivery_method = :sendmail"
  gsub_file 'config/environments/production.rb', /config.action_mailer.default_url_options = .*/, "config.action_mailer.default_url_options = { :host => '#{prefs[:deploy_server]}' }"
end

after_everything do
  # This block is run after the 'after_bundler' block.
  # Use this section to finalize the application.
  # Run database migrations or make a final git commit.
  prefs[:deploy_repo] = `git remote -v | perl -nE 'm/^\\w+\\s+(\\S+)\\s+\\(fetch\\)/ && print $1'` unless prefs.has_key? :deploy_repo
  prefs[:deploy_repo] = ask_wizard "Repository to fetch from:" if prefs[:deploy_repo].empty?
  inject_into_file 'config/deploy.rb', prefs[:deploy_repo], :after => 'ssh://'

  ### GIT ###
  if prefer :git, true
    git :add => '-A'
    git :commit => '-qm "rails_apps_composer: add capistrano configuration"'
  end
end

# A recipe has two parts: the Ruby code and YAML matter that comes
# after a blank line with the __END__ keyword.

__END__

name: capistrano
description: "Adds capistrano deployment"
author: kassi

requires: [setup]
run_after: [setup, mysql, extras, bitbucket]
category: configuration
