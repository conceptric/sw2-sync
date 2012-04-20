require File.join(File.dirname(__FILE__), *%w[.. lib remote_jobs.rb])

class MockJob                             
  include RemoteJobs

  @@jobs = []
    
  attr_reader :attributes
  
  def initialize(attributes)
    @attributes = attributes
  end

  def self.find
    @@jobs
  end
  
  def self.create(attributes)
    @@jobs << self.new(attributes)
  end    

  def self.reset
    @@jobs = []
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

describe RemoteJobs do

  describe "Jobs that exist remotely but not locally" do

    def stub_remote_jobs(how_many)
      jobs = []
      how_many.times do |i| 
        jobs << {reference:"#{i+1}", title: 'job title'}
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
      jobs.first.attributes.
        should == {reference:'1', title: 'job title'}
    end

    it "create two new jobs using the remote attributes" do
      stub_remote_jobs(2)
      MockJob.sync_with('remote_url') { MockJob.find }
      jobs = MockJob.find
      jobs.size.should == 2
      jobs.first.attributes.should == {reference:'1', title: 'job title'}
      jobs.last.attributes.should == {reference:'2', title: 'job title'}
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

describe "RemoteJobs Interfaces" do

  describe ".find_jobs_to_sync" do                   
    subject { MockJob.find_jobs_to_sync { MockJob.find } }
    
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
        MockJob.reset
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
