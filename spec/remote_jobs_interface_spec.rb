require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RemoteJobs Interfaces" do

  describe ".find_jobs_to_sync" do
                       
    subject { MockJob.find_jobs_to_sync { MockJob.find } }

    before(:each) do
      MockJob.reset
      MockJob.find.size.should == 0 
    end            
    
    it "returns an array" do      
      subject.should be_instance_of Array
    end
    
    context "when there are jobs to sync" do
      it "of jobs to be synchronised with the remote source" do            
        MockJob.create({})
        subject.size.should_not == 0
        subject.each {|job| job.should be_instance_of MockJob}
      end
    end

    context "when there aren't any jobs to sync" do
      subject { MockJob.find_jobs_to_sync  { MockJob.find } }
      
      it "returns an empty array" do            
        subject.size.should == 0
      end
    end
    
  end
  
  describe ".find_remote_jobs" do

    subject { MockJob.find_remote_jobs('remote_url') }

    before(:each) do 
      RemoteXmlReader.stub(:new).with('remote_url').
        and_return(MockRemoteXmlReader.new)            
    end
    
    it "takes a remote url and returns an array" do
      subject.should be_instance_of Hash 
    end

    context "when there are remote jobs" do
      it "of job attributes to be synchronised with the local database" do            
        subject.size.should_not == 0
        subject.each {|reference, job| job.should be_instance_of Hash}
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
