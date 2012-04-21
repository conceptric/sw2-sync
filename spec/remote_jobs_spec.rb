require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RemoteJobs do

  def stub_remote_jobs(how_many)
    jobs = {}
    how_many.times do |i| 
      jobs["#{i+1}"]= { reference: "#{i+1}", title: "job title #{i+1}" }
    end
    MockJob.stub(:find_remote_jobs).
      and_return(jobs)      
  end

  def local_jobs_fixtures(how_many)
    jobs = []
    how_many.times do |i| 
      MockJob.create({ reference: "#{i+1}", title: "job title #{i+2}" })
    end
  end

  def update_setup(how_many_remote, how_many_local)
    stub_remote_jobs(how_many_remote)
    local_jobs_fixtures(how_many_local)                                      
  end
  
  def verify_test_database(number=1)
    existing_jobs = MockJob.find
    existing_jobs.size.should == number      
    existing_jobs.first.reference.should == '1'
    existing_jobs.first.attributes.
      should == { reference: '1', title: 'job title 2' }       
  end                                                       

  describe "Jobs that exist remotely with an empty local database" do

    before(:each) do
      MockJob.reset
      MockJob.find.size.should == 0 
    end            
    
    it "create a new job using the remote attributes" do
      stub_remote_jobs(1)
      MockJob.sync_with('remote_url') { MockJob.find }
      jobs = MockJob.find
      jobs.size.should == 1
      jobs.first.attributes.should == { reference: '1', title: 'job title 1' }
    end

    it "create two new jobs using the remote attributes" do
      stub_remote_jobs(2)
      MockJob.sync_with('remote_url') { MockJob.find }
      jobs = MockJob.find
      jobs.size.should == 2
      jobs.first.attributes.should == { reference: '1', title: 'job title 1' }
      jobs.last.attributes.should == { reference: '2', title: 'job title 2' }
    end                                                     
    
  end
    
  describe "Jobs that exist remotely with a local database containing jobs" do

    before(:each) do
      MockJob.reset      
    end
      
    context "the remote job matches one in the local database" do
      it "updates the existing job using the remote attributes" do
        update_setup(1, 1)
        verify_test_database
        
        MockJob.sync_with('remote_url') { MockJob.find }
        
        updated_jobs = MockJob.find      
        updated_jobs.size.should == 1      
        updated_jobs.first.reference.should == '1'
        updated_jobs.first.attributes.
          should == { reference: '1', title: 'job title 1' }
      end      

      it "only updates the referenced job using the remote attributes" do
        update_setup(1, 3)
        verify_test_database(3)

        MockJob.sync_with('remote_url') { MockJob.find }

        updated_jobs = MockJob.find
        updated_jobs.size.should == 3      
        updated_jobs.first.reference.should == '1'
        updated_jobs.first.attributes.
          should == { reference: '1', title: 'job title 1' }
      end
    end
    
    context "the remote job does not match anything in the local database" do
      it "adds the new job to the database using the remote attributes" do
        local_jobs_fixtures(2)                                      
        verify_test_database(2)
        MockJob.stub(:find_remote_jobs).
          and_return({'5' => {reference: '5', title: 'job title 5'}})      

        MockJob.sync_with('remote_url') { MockJob.find }
        MockJob.find.size.should == 3      
      end
    end      
  end                                      

  describe "Jobs that no longer exist in the remote source" do
    it "mark the job as not to be published"
  end

  describe "Remote attributes cause validation errors" do
    it "leaves the local job unchanged and writes an error to the log"
  end
  
end