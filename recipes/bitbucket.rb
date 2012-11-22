before_config do
  # Code here is run before any configuration prompts.

  say_wizard "Checking if bitbucket command line tool is installed"
  cli = `which bitbucket`
  if cli.empty?
    raise "Please install bitbucket command line tool with\n  pip install bitbucket"
  end

  dotfile = `cat ~/.bitbucket`
  if dotfile.empty?
    prefs[:bitbucket_user] = ask_wizard "What is your Bitbucket user name?" unless prefs.has_key? :bitbucket_user
    `echo "[auth]\nusername = #{prefs[:bitbucket_user]}\n\n[options]\nscm = git\nprotocol = ssh\n" > ~/.bitbucket`
    create_file "~/.bitbucket"
  else
    prefs[:bitbucket_user] = `grep username ~/.bitbucket | perl -nE 'm/=\s*(\w+)/ && say $1'`
  end

  prefs[:bitbucket_alias] = `git config --global --get-regex alias\. | perl -nE 'm/^alias\.(\w+)\s+!bitbucket/ && say $1'`
  if prefs[:bitbucket_alias].empty?
    raise <<-RAISE
    Please add a git alias using the bitbucket command line tool to ~/.gitconfig
    An example for Mac OSX would be
      create-bucket = !bitbucket create-from-local --password $(security find-internet-password -a #{prefs[:bitbucket_user]} -s bitbucket.org -g 2>&1 1>/dev/null | ruby -e 'print $1 if STDIN.gets =~ /^password: \"(.*)\"$/')
RAISE
  end

end

after_bundler do
  # Code here is run after Bundler installs all the gems for the project.
  # Use this section to run generators and rake tasks.
  # Download any files from a repository for models, controllers, views, and routes.
end

after_everything do
  # This block is run after the 'after_bundler' block.
  # Use this section to finalize the application.
  # Run database migrations or make a final git commit.
  run "git #{prefs[:bitbucket_alias]}"
end

__END__

name: bitbucket
description: "Creates a remote repository on bitbucket"
author: kassi

requires: [git]
run_after: [git,extras]
category: configuration
