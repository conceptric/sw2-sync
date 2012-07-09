require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RemoteJobs interfaces with the local database" do

  describe ".find_jobs_to_sync() from the local database" do

    subject { MockJob.find_jobs_to_sync { MockJob.find } }

    before(:each) do
      MockJob.reset
      MockJob.find.size.should == 0
    end

    it "returns an array" do
      subject.should be_instance_of Array
    end

    context "when there are local jobs to sync" do

      it "returns an array containing the Job to be synchronised" do
        MockJob.create({})
        subject.size.should_not == 0
        subject.each {|job| job.should be_instance_of MockJob}
      end

    end

    context "when there aren't any local jobs to sync" do

      subject { MockJob.find_jobs_to_sync  { MockJob.find } }

      it "returns an empty array" do
        subject.size.should == 0
      end

    end

  end

end

describe "RemoteJobs interfaces with the remote source" do

  describe ".find_remote_jobs" do

    SW2_FIXTURES = File.join(File.dirname(__FILE__), *%w[fixtures sw2])

    subject { MockJob.find_remote_jobs('remote_url') }

    context "when there aren't any remote jobs" do

      before(:each) do
        sw2_xml_reader_setup('sw2_xml_api.xml')
      end

      it "returns a hash" do
        subject.should be_instance_of Hash
      end

      it "which is empty" do
        subject.size.should == 0
      end

    end

    context "when there are remote jobs" do

      before(:each) do
        sw2_xml_reader_setup('sw2_single_job_example.xml')
      end

      it "returns a hash" do
        subject.should be_instance_of Hash
      end

      it "containing job attributes hashes" do
        subject.each {|reference, job| job.should be_instance_of Hash}
      end

      it "removes job keys and value from the hash not defined by the Job model" do
        subject.each do |reference, job|
          job_keys = job.keys.collect! {|key| key.to_s}
          job_keys.sort.should == MockJob._accessible_attributes[:default].sort
        end
      end

    end

  end

end
