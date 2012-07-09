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

  let(:sw2_keys) { ["reference", "contactemail",
        "contactname", "description", "jobtype",
        "location", "salary", "title"] }

  describe ".find_remote_jobs" do

    SW2_FIXTURES = File.join(File.dirname(__FILE__), *%w[fixtures sw2])

    subject { MockJob.find_remote_jobs('remote_url') }

    context "when there aren't any remote jobs" do

      before(:each) do
        sw2_xml_reader_setup('sw2_xml_api.xml')
        MockJob.set_attributes_list(sw2_keys)
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

      describe "hash attributes are defined by the local Model attributes" do

        it "MockJob returns a complete set of attributes for SW2" do
          MockJob.set_attributes_list(sw2_keys)
          MockJob._accessible_attributes[:default].sort.should == sw2_keys.sort
        end

        it "Mockjob returns the attribute list that I set" do
          attribute_list = sw2_keys.first(3)
          MockJob.set_attributes_list(attribute_list)
          MockJob._accessible_attributes[:default].sort.should == attribute_list.sort
        end

        context "when all the Model attributes match the hash keys" do

          it "hash attributes match the Model attributes" do
            MockJob.set_attributes_list(sw2_keys)
            subject.each do |reference, job|
              job_keys = job.keys.collect! {|key| key.to_s}
              job_keys.sort.should == MockJob._accessible_attributes[:default].sort
            end
          end

        end

        context "when the Model attributes are a subset of the hash keys" do

          it "removes the extra keys from the hashes" do
            attribute_list = sw2_keys.first(3)
            MockJob.set_attributes_list(attribute_list)
            subject.each do |reference, job|
              job_keys = job.keys.collect! {|key| key.to_s}
              job_keys.sort.should == attribute_list.sort
            end
          end

        end

        context "when the Model contains attributes not in the hash keys" do

          let(:attribute_list) { sw2_keys << 'missing' }

          it "the missing attribute is added to the MockJob attributes" do
            MockJob.set_attributes_list(attribute_list)
            MockJob._accessible_attributes[:default].should include 'missing'
          end

          it "the missing attribute is ignored in the hashes" do
            MockJob.set_attributes_list(attribute_list)
            subject.each do |reference, job|
              job_keys = job.keys.collect! {|key| key.to_s}
              job_keys.should_not include 'missing'
            end
          end

        end

      end

    end

  end

end
