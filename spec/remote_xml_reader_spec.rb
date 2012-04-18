require File.join(File.dirname(__FILE__), *%w[.. lib remote_xml_reader.rb])
FIXTURES = File.join(File.dirname(__FILE__), *%w[fixtures])

def fixture_stream_helper(filename)
  StringIO.new(File.read(File.join(FIXTURES, filename)))
end

describe RemoteXmlReader do

  let(:test_url) { 'http://www.job-tv.co.uk/XML.asp' }
  
  describe ".open" do
    it "opens a remote url" do
      RemoteXmlReader.should_receive(:open).once.and_return(
        fixture_stream_helper('sw2_harder_example.xml'))
      RemoteXmlReader.open(test_url).read.
          should == open(FIXTURES + '/sw2_harder_example.xml').read  
    end    
  end  

  describe ".new" do
    before(:each) do
      RemoteXmlReader.stub(:open).and_return(
        open(FIXTURES + '/sw2_harder_example.xml'))      
    end

    it "creates a new instance" do
      RemoteXmlReader.new('remote_url').
        should be_instance_of(RemoteXmlReader)      
    end        

    it "that contains the target xml" do
      RemoteXmlReader.new('remote_url').read.
        should == open(FIXTURES + '/sw2_harder_example.xml').read
    end        
  end

  describe ".extract_named_nodes" do
    before(:each) do
      RemoteXmlReader.stub(:open).and_return(
        open(FIXTURES + '/sw2_harder_example.xml'))      
      @remote_xml_reader = RemoteXmlReader.new('remote_url')
    end
  
    it "returns an array of nodes matching the name" do
      result = @remote_xml_reader.extract_named_nodes('item')
      result.should be_instance_of(Array)
      result.count.should == 2          
    end                                                        
    
    it "each of these data nodes are Nokogiri elements" do
      result = @remote_xml_reader.extract_named_nodes('item')
      result.first.should be_instance_of(Nokogiri::XML::Element)      
    end
  
    it "each element contains the correct amount of data" do
      result = @remote_xml_reader.extract_named_nodes('item')
      result.first.children.size.should == 29
      result.last.children.size.should == 29
    end
  
    it "each element contains the correct data" do
      result = @remote_xml_reader.extract_named_nodes('item')
      result.first.search('reference').text.should == '06468'
      result.last.search('reference').text.should == '06469'
    end
  end 
end
  
