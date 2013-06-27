deployflow
==========

deployflow lets you use git-flow (or any git tag-based versioning strategy, really) 
to release into a 'staging' branch and then promote specific tags into your 'master'
branch for deploying to production. It's for those of us who are persnickety about
keeping 'master' as a canonical repository of what's actually running in production 
and doing all our mucking about elsewhere.


Installation
------------

1.  git-flow

    I'd recommend you use my custom fork of git-flow with deployflow. It adds
    version number auto-incrementation and suppresses the need to add a message
    to each tag you create. You can install it by:

    `brew uninstall git-flow` (if you've previously installed git-flow via Homebrew)  
    `git clone --recursive git://github.com/nmeans/gitflow.git`  
    `cd gitflow`  
    `make install` (or `sudo make install` if you don't own /usr/local/bin)  

    If you'd prefer the original, visit [http://github.com/nvie/gitflow](http://github.com/nvie/gitflow)
    for install information.

2.  deployflow 

    `gem install deployflow`

    This will also install capistrano and capistrano-ext if you don't already have them.


Repository Setup
----------------

1.  Add a couple of required branches to your repo

    If you don't already have them, you'll need to add 'develop' and 'staging' branches. You should have a 'master' branch by default. eg:

    `git branch develop`  
    `git branch staging`  

2.  Run `git flow init` on your repo

    You'll want to use 'staging' as your branch for production releases (contradictory, I know, but trust me)
    and 'develop' for next release development. eg:

        [~/Projects/deployflow-test]$ git flow init

        Which branch should be used for bringing forth production releases?
          - develop
          - master
          - staging
        Branch name for production releases: [master] staging

        Which branch should be used for integration of the "next release"?
          - develop
          - master
        Branch name for "next release" development: [develop] develop
    

3.  Add the following to the top of your config/deploy.rb

    `require 'capistrano/ext/multistage'`  
    `require 'capistrano/deployflow'`  


Usage
-----

Just use git-flow like normal. (What is 'normal'? 
[Here's a good primer.](http://jeffkreeftmeijer.com/2010/why-arent-you-using-git-flow/)) 
Create a release you want to deploy with `git flow release` or `git flow hotfix`.

When you're ready to deploy your release to staging, no need to push first, just run `cap staging deploy` and
deployflow will automatically push to origin and deploy your most recent tag to staging.

After you've tested in staging, you're ready to promote your tag to master and roll it out to production. All
you have to do is `cap production deploy`, and deployflow will ask which tag you'd like to promote (suggesting
your most recent automatically), merge that tag over to your master branch, push to origin, and deploy that tag 
to production.

For non-interactive deployments you can also specify the tag with tag="tag name". For example you can do
`cap production deploy tag=production_20130626`.

Credits
-------

Heavily inspired by and some code from Josh Nichols' [capistrano-gitflow](https://github.com/technicalpickles/capistrano-gitflow),
which was in turn inspired by Alan Pinstein's [git-deployment](https://github.com/apinstein/git-deployment).

Copyright
---------

Copyright (c) 2011 Nickolas Means / ActiveProspect, Inc. See LICENSE.txt for further details.
