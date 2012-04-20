require File.join(File.dirname(__FILE__), *%w[.. lib remote_jobs.rb])

class Job
  include RemoteJobs
  
  def self.find_with_reference
    [] << self.new
  end
end

describe RemoteJobs do

  describe ".find_jobs_to_sync" do    
    it "return an array" do      
      Job.find_jobs_to_sync.should be_instance_of Array
    end

    it "of jobs to be synchronised with the remote source" do      
      jobs = Job.find_jobs_to_sync
      jobs.size.should_not == 0
      jobs.each {|job| job.should be_instance_of(Job)}
    end
  end  
 
end
