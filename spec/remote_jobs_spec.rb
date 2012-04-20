require File.join(File.dirname(__FILE__), *%w[.. lib remote_jobs.rb])
class MockJob
  include RemoteJobs

  def self.find
    [] << self.new
  end
end

class MockNoJob < MockJob
  def self.find
    []
  end  
end

class MockRemoteXmlReader  
  def child_nodes_to_hash(node_name)
    [{reference:'1', title: 'job title'}]
  end  
end

class MockEmptyRemoteXmlReader  
  def child_nodes_to_hash(node_name)
    []
  end  
end

describe "RemoteJobs Interfaces" do

  describe ".find_jobs_to_sync" do    
    subject { MockJob.find_jobs_to_sync { MockJob.find } }
    
    it "returns an array" do      
      subject.should be_instance_of Array
    end
    
    context "when there are jobs to sync" do
      it "of jobs to be synchronised with the remote source" do            
        subject.size.should_not == 0
        subject.each {|job| job.should be_instance_of MockJob}
      end
    end

    context "when there aren't any jobs to sync" do
      subject { MockJob.find_jobs_to_sync  { MockNoJob.find } }
      
      it "returns an empty array" do            
        subject.size.should == 0
      end
    end
  end
  
  describe ".find_remote_jobs" do

    before(:each) do 
      RemoteXmlReader.stub(:new).with('remote_url').
        and_return(MockRemoteXmlReader.new)            
    end

    subject { MockJob.find_remote_jobs('remote_url') }
        
    it "takes a remote url and returns an array" do
      subject.should be_instance_of Array 
    end

    context "when there are remote jobs" do
      it "of job attributes to be synchronised with the local database" do            
        subject.size.should_not == 0
        subject.each {|job| job.should be_instance_of Hash}
      end
    end

    context "when there aren't any remote jobs" do     
      before(:each) do 
        RemoteXmlReader.stub(:new).with('remote_url').
          and_return(MockEmptyRemoteXmlReader.new)            
      end

      it "returns an empty array" do            
        subject.size.should == 0
      end
    end    

  end  
 
end
