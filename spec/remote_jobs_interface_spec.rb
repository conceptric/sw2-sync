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
    SW2_FIXTURES = File.join(File.dirname(__FILE__), *%w[fixtures sw2])

    def sw2_xml_reader_setup(filename)
      xml_file = open(SW2_FIXTURES + '/' + filename)
      Remote::Xml::Reader.stub(:open).and_return(xml_file)      
      MockJob.find_remote_jobs('remote_url')
    end
    
    it "takes a remote url and returns an array" do
      remote_jobs = sw2_xml_reader_setup('sw2_xml_api.xml')
      remote_jobs.should be_instance_of Hash 
    end
    
    context "when there aren't any remote jobs" do     
      it "returns an empty array" do            
        remote_jobs = sw2_xml_reader_setup('sw2_xml_api.xml')
        remote_jobs.size.should == 0
      end
    end    
    
    context "when there are remote jobs" do
      it "of job attributes to be synchronised with the local database" do            
        remote_jobs = sw2_xml_reader_setup('sw2_single_job_example.xml')
        remote_jobs.size.should_not == 0
        remote_jobs.each {|reference, job| job.should be_instance_of Hash}
      end          
      
      it "hash attributes that are not present in the Model are removed" do
        remote_jobs = sw2_xml_reader_setup('sw2_single_job_example.xml')
        remote_jobs.each do |reference, job| 
          job_keys = job.keys.collect! {|key| key.to_s}
          job_keys.sort.should == MockJob._accessible_attributes[:default].sort
        end
      end      
    end
  end  
 
end
