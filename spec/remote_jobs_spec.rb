require File.join(File.dirname(__FILE__), *%w[.. lib remote_jobs.rb])

class MockJob
  include RemoteJobs
  
  def self.find_with_reference
    [] << self.new
  end
end

class MockNoJob
  include RemoteJobs
  
  def self.find_with_reference
    []
  end
end

describe RemoteJobs do
  
  describe ".find_jobs_to_sync" do    
    subject { MockJob.find_jobs_to_sync }
    
    it "returns an array" do      
      subject.should be_instance_of Array
    end
    
    context "when there are jobs to sync" do
      it "of jobs to be synchronised with the remote source" do            
        subject.size.should_not == 0
        subject.each {|job| job.should be_instance_of(MockJob)}
      end
    end

    context "when there aren't any jobs to sync" do
      subject { MockNoJob.find_jobs_to_sync }
      
      it "of jobs to be synchronised with the remote source" do            
        subject.size.should == 0
      end
    end

  end  
 
end
