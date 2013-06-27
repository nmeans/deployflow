require 'capistrano'

module Capistrano
  class Deployflow
    def self.load_into(capistrano_configuration)
      capistrano_configuration.load do
        before "deploy:update_code", "deployflow:set_deploy_codebase"
        before "deployflow:set_deploy_codebase", "deployflow:verify_up_to_date"

        namespace :deployflow do

          def most_recent_tag
            `git for-each-ref --sort='*authordate' --format='%(refname:short)' refs/tags | sed '$!d'`.chomp
          end

          def ask_which_tag
            if ENV['tag']
              promote_tag = ENV['tag']
            else
              tag = Capistrano::CLI.ui.ask("What tag would you like to promote to #{stage}? [#{most_recent_tag}]")
              promote_tag = tag == "" ? most_recent_tag : tag
            end

            # Do we have this tag?
            abort "Tag '#{promote_tag}' does not exist!" unless `git tag`.split(/\n/).include?(promote_tag)

            puts "Promoting #{promote_tag} to #{stage}."
            return promote_tag
          end

          desc "Set the tag to deploy to the selected stage."
          task :set_deploy_codebase do
            abort "Unsupported stage: #{stage}." unless [:staging, :production].include?(stage)
            if stage == :staging
              # Ask which tag to deploy
              tag_to_deploy = ask_which_tag
              # Push to origin staging
              system "git push --tags origin staging"
              abort "Git push failed!" if $? != 0
              # Set deploy codebase to our tag
              set :branch, tag_to_deploy
            elsif stage == :production
              tag_to_deploy = ask_which_tag
              # Switch to 'master'
              system "git checkout master"
              abort "Could not switch to 'master' branch!" if $? != 0
              # Merge select tag into master
              system "git merge --no-ff #{tag_to_deploy}"
              abort "Could not merge tag '#{tag_to_deploy}' into master!" if $? != 0
              # Push to origin master
              system "git push --tags origin master"
              abort "Git push failed!" if $? != 0
              # Set our deploy codebase to our tag
              system "git checkout develop"
              puts "*** Could not switch back to 'develop' branch! Be sure to manually switch before continuing work." if $? != 0
              set :branch, tag_to_deploy
            end

          end

          task :verify_up_to_date do
            set :local_branch, `git branch --no-color 2> /dev/null | sed -e '/^[^*]/d'`.gsub(/\* /, '').chomp
            set :local_sha, `git log --pretty=format:%H HEAD -1`.chomp
            set :origin_sha, `git log --pretty=format:%H #{local_branch} -1`
            unless local_sha == origin_sha
              abort """
Your #{local_branch} branch is not up to date with origin/#{local_branch}.
Please make sure you have pulled and pushed all code before deploying:

    git pull origin #{local_branch}
    # run tests, etc
    git push origin #{local_branch}

    """
            end
          end

        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capistrano::Deployflow.load_into(Capistrano::Configuration.instance)
end
