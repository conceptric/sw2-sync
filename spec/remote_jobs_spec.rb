require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RemoteJobs do

  describe "Jobs that exist remotely but not locally" do

    def stub_remote_jobs(how_many)
      jobs = {}
      how_many.times do |i| 
        jobs["#{i+1}"]= { title: "job title #{i+1}" }
      end
      MockJob.stub(:find_remote_jobs).
        and_return(jobs)      
    end
    
    before(:each) do
      MockJob.reset
      MockJob.find.size.should == 0 
    end            
    
    it "create a new job using the remote attributes" do
      stub_remote_jobs(1)
      MockJob.sync_with('remote_url') { MockJob.find }
      jobs = MockJob.find
      jobs.size.should == 1
      jobs.first.attributes.should == { title: 'job title 1' }
    end

    it "create two new jobs using the remote attributes" do
      stub_remote_jobs(2)
      MockJob.sync_with('remote_url') { MockJob.find }
      jobs = MockJob.find
      jobs.size.should == 2
      jobs.first.attributes.should == { title: 'job title 1' }
      jobs.last.attributes.should == { title: 'job title 2' }
    end                                                     
    
  end
    
  describe "Jobs that exist remotely and locally" do
    it "update the existing job using the remote attributes"
  end                                      

  describe "Remote attributes cause validation errors" do
    it "leaves the local job unchanged and writes an error to the log"
  end

  describe "Jobs that no longer exist in the remote source" do
    it "mark the job as not to be published"
  end
  
end