require 'capistrano'

module Capistrano
  class Deployflow
    def self.load_into(capistrano_configuration)
      capistrano_configuration.load do
        before "deploy:update_code", "deployflow:set_deploy_codebase"

        namespace :deployflow do

          def most_recent_tag
            `git for-each-ref --sort='*authordate' --format='%(tag)' refs/tags | sed '$!d'`
          end

          desc "Pick the most recent tag in staging branch for deploy"
          task :set_deploy_codebase do
            abort "Unsupported stage: #{stage}." unless [:staging, :production].include?(stage)
            if stage == :staging
              system "git push --tags origin staging"
              abort "Git push failed!" if $? != 0
              set :branch, most_recent_tag
            elsif stage == :production
              tag = Capistrano::CLI.ui.ask("What tag would you like to promote to production? [#{most_recent_tag}]")
              if tag == ""
                promote_tag = most_recent_tag
              else
                # Do we have this tag?
                abort "Tag '#{tag}' does not exist!" unless `git tag`.split(/\n/).include?(tag)
                promote_tag = tag
              end
              # Merge promote_tag into our master branch and push to GitHub
              system "git checkout master"
              abort "Could not switch to 'master' branch!" if $? != 0
              system "git merge --no-ff #{most_recent_tag}"
              abort "Could not merge tag '#{most_recent_tag}' into master!" if $? != 0
              system "git push origin master"
              abort "Git push failed!" if $? != 0
              # Set our deploy codebase to origin/master
              set :branch, 'master'
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
