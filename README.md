# SW2 Sync: SW2 recruitment software website integrations

This is a project aimed at providing synchronisation between Jobs on a local Rails application and those provided by a remote XML feed from SW2 software.

This is a work in progress, so there are no guarantees!

## Installation

Add the gem to your Gemfile and run bundle install.
              
    be rails g migration AddReferenceToJob reference
    be rails g migration AddPublishedToJob published:boolean

You'll need to edit the generated migrations to ensure that the *published* column cannot be null and has a default value of true.

Require the gem library, and include the RemoteJobs module in the Model.

    require 'sw2-sync'
                      
    class Model < ActiveRecord::Base
      include RemoteJobs
      
Make sure to add the *:reference* attribute to *attr_accessible* statement in your Model so that it can be mass assigned when creating and updating Jobs.

You'll need a couple of new methods in your Model, these may be moved into the module in due course.

    def self.find_remotely_referenced_jobs
      Model.where("reference != ?", '')
    end

    def unpublish
      self.published = false
      self.save
    end

At this point it should be working when invoked, but remember... no guarantees.

    Model.sync_with('The remote source url of your choice')
    
I intend to use a Rake task to invoke this command, and combine it with a Cron job.

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. I'll decide whether I want to include it.

## Copyright

Copyright (c) 2012 James Whinfrey. See LICENSE for details.
