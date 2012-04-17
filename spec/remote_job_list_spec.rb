require File.join(File.dirname(__FILE__), *%w[.. lib remote_job_list.rb])
FIXTURES = File.join(File.dirname(__FILE__), *%w[fixtures])

def fixture_stream_helper(filename)
  StringIO.new(File.read(File.join(FIXTURES, filename)))
end

describe RemoteJobsList do
  
  describe "a single simple job" do 
    before(:each) do
      RemoteXmlReader.should_receive(:open).once.
      and_return(fixture_stream_helper('sw2_simple_example.xml'))
      @job_list = RemoteJobsList.new('simple')
    end                                           
  
    describe ".new" do    
      it "creates a new instance" do
        @job_list.should be_instance_of(RemoteJobsList)
      end
    end  

    describe ".to_hash" do
      it "returns an array of attribute hashes" do
        attributes = @job_list.to_hash
        attributes.should be_instance_of(Array)
        attributes.first.should be_instance_of(Hash)
      end 

      it "contains a single set of job attributes" do
        @job_list.to_hash.count.should == 1
      end                                

      it "has a reference number key with the right value" do
        @job_list.to_hash.first[:reference].should == '06468'
      end

      it "has all the SW2 API attributes" do
        @job_list.to_hash.first.should include(:title)
        @job_list.to_hash.first.should include(:category)
        @job_list.to_hash.first.should include(:jobtype)
        @job_list.to_hash.first.should include(:startdate)
        @job_list.to_hash.first.should include(:enddate)
        @job_list.to_hash.first.should include(:duration)
        @job_list.to_hash.first.should include(:pubDate)
        @job_list.to_hash.first.should include(:salary)
        @job_list.to_hash.first.should include(:location)
        @job_list.to_hash.first.should include(:joboftheweek)
        @job_list.to_hash.first.should include(:contactname)
        @job_list.to_hash.first.should include(:contactemail)
        @job_list.to_hash.first.should include(:description)
      end
    end        
  end      
  
  describe "a more complex remote feed" do
    before(:each) do
      RemoteXmlReader.should_receive(:open).once.
      and_return(fixture_stream_helper('sw2_harder_example.xml'))
      @multi_job_list = RemoteJobsList.new('url')
    end
    
    describe ".to_hash" do
      it "returns an array of attribute hashes" do
        attributes = @multi_job_list.to_hash
        attributes.should be_instance_of(Array)
        attributes.first.should be_instance_of(Hash)
      end 
       
      it "contains multiple sets of job attributes" do
        @multi_job_list.to_hash.count.should == 2
      end      

      it "has a reference number key with the right value" do
        @multi_job_list.to_hash.first[:reference].should == '06468'
        @multi_job_list.to_hash.last[:reference].should == '06469'
      end
    end
  end
end
