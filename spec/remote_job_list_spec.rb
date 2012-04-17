require File.join(File.dirname(__FILE__), *%w[.. lib remote_job_list.rb])
FIXTURES = File.join(File.dirname(__FILE__), *%w[fixtures])

def fixture_stream_helper(filename)
  StringIO.new(File.read(File.join(FIXTURES, filename)))
end

describe RemoteJobsList do

  before(:each) do
    RemoteXmlReader.should_receive(:open).
    and_return(fixture_stream_helper('sw2_simple_example.xml'))
  end                                           

  describe ".new" do    
    it "creates a new instance" do
      RemoteJobsList.new('simple').should be_instance_of(RemoteJobsList)
    end
  end  
 
end
