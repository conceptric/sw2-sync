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

  def local_jobs_fixtures(how_many_sync, how_many_static=0)
    jobs = []
    how_many_sync.times do |i| 
      MockJob.create({ reference: "#{i+1}", title: "job title #{i+2}" })
    end
    how_many_static.times do |i| 
      MockJob.create({ reference: nil, title: "static job title #{i+1}" })
    end
  end

  def update_setup(how_many_remote, how_many_local, how_many_static=0)
    stub_remote_jobs(how_many_remote)
    local_jobs_fixtures(how_many_local, how_many_static)                                      
  end
  
  def verify_test_database(number=1)
    existing_jobs = MockJob.find_remotely_referenced_jobs
    existing_jobs.size.should == number      
  end                                                       

  describe "Jobs that exist remotely with an empty local database" do

    before(:each) do
      MockJob.reset
      MockJob.find.size.should == 0 
    end            
    
    it "create a new job using the remote attributes" do
      stub_remote_jobs(1)
      MockJob.sync_with('remote_url')
      jobs = MockJob.find
      jobs.size.should == 1
      jobs.first.attributes.should == { reference: '1', title: 'job title 1' }
    end

    it "create two new jobs using the remote attributes" do
      stub_remote_jobs(2)
      MockJob.sync_with('remote_url')
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
        update_setup(1, 1, 0)
        verify_test_database
        
        MockJob.sync_with('remote_url')
        
        MockJob.find.size.should == 1
        updated_jobs = MockJob.find_remotely_referenced_jobs      
        updated_jobs.size.should == 1      
        updated_jobs.first.reference.should == '1'
        updated_jobs.first.attributes.
          should == { reference: '1', title: 'job title 1' }
      end      

      it "only updates the referenced job using the remote attributes" do
        update_setup(1, 1, 2)
        verify_test_database(1)

        MockJob.sync_with('remote_url')

        MockJob.find.size.should == 3
        updated_jobs = MockJob.find_remotely_referenced_jobs
        updated_jobs.size.should == 1      
        updated_jobs.first.reference.should == '1'
        updated_jobs.first.attributes.
          should == { reference: '1', title: 'job title 1' }
      end
    end
    
    context "the remote job does not match anything in the local database" do
      it "adds the new job to the database using the remote attributes" do
        update_setup(1, 0, 1)                                      
        verify_test_database(0)
        MockJob.stub(:find_remote_jobs).
          and_return({'5' => {reference: '5', title: 'job title 5'}})      

        MockJob.sync_with('remote_url')
        MockJob.find.size.should == 2      
      end
    end      
  end                                      

  describe "Jobs that no longer exist in the remote source" do
    
    def setup_delete_specs(sync, static=0)
      local_jobs_fixtures(sync, static) 
      verify_test_database(sync)      
    end                        
    
    before(:each) do
      MockJob.reset      
    end    
    
    it "mark the job as not to be published" do        
      setup_delete_specs(1)
      MockJob.stub(:find_remote_jobs).and_return({})      

      MockJob.sync_with('remote_url')

      MockJob.find_remotely_referenced_jobs.size.should == 1
      MockJob.find_remotely_referenced_jobs.first.published.should be_false            
    end

    it "mark all the jobs as not to be published" do        
      setup_delete_specs(3)
      MockJob.stub(:find_remote_jobs).and_return({})      

      MockJob.sync_with('remote_url')

      remote_jobs = MockJob.find_remotely_referenced_jobs
      remote_jobs.size.should == 3
      remote_jobs.each do |job|
        job.published.should be_false            
      end      
    end
    
    it "only mark those as not to be published" do        
      setup_delete_specs(2)
      MockJob.stub(:find_remote_jobs).
        and_return({'1' => {reference: '1', title: 'job title 2'}})      

      MockJob.sync_with('remote_url')

      MockJob.find_remotely_referenced_jobs.size.should == 2
      MockJob.find_by_reference('1').published.should be_true            
      MockJob.find_by_reference('2').published.should be_false            
    end
        
    it "jobs without a reference should not be affected" do        
      setup_delete_specs(0, 2)
      MockJob.stub(:find_remote_jobs).and_return({})      

      MockJob.sync_with('remote_url')

      jobs = MockJob.find
      jobs.size.should == 2
      jobs.each do |job|
        job.published.should be_true            
      end      
    end
        
  end
  
  describe "Remote attributes cause validation errors" do
    
    it "leaves the local job unchanged catching errors" do
      MockJob.stub(:create).and_raise(StandardError)
      MockJob.stub(:find_remote_jobs).
        and_return({'1' => {reference: '1', title: 'job title 2'}})      
      expect { MockJob.sync_with('remote_url') }.should_not raise_error
    end

  end
  
end