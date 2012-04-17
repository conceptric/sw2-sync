require File.join(File.dirname(__FILE__), *%w[.. lib remote_xml_reader.rb])
FIXTURES = File.join(File.dirname(__FILE__), *%w[fixtures])

describe RemoteXmlReader do

  let(:test_url) { 'http://www.job-tv.co.uk/XML.asp' }
  
  describe ".open" do
    it "opens a remote url and reads the contents" do
      subject.should_receive(:open).
        once.
        with(test_url).
        and_return(
        StringIO.new(File.read(File.join(File.dirname(__FILE__), 
          *%w[fixtures sw2_harder_example.xml])))
        )
      subject.open(test_url)  
    end    
  end  

  describe ".extract_named_nodes" do
    before(:each) do
      subject.stub(:open).and_return(
        open(FIXTURES + '/sw2_harder_example.xml'))      
    end

    it "returns an array of nodes matching the name" do
      result = subject.extract_named_nodes('feed_url', 'item')
      result.should be_instance_of(Array)
      result.count.should == 2          
    end                                                        
    
    it "each of these data nodes are Nokogiri elements" do
      result = subject.extract_named_nodes('feed_url', 'item')
      result.first.should be_instance_of(Nokogiri::XML::Element)      
    end

    it "each element contains the correct amount of data" do
      result = subject.extract_named_nodes('feed_url', 'item')
      result.first.children.size.should == 29
      result.last.children.size.should == 29
    end

    it "each element contains the correct data" do
      result = subject.extract_named_nodes('feed_url', 'item')
      result.first.search('reference').text.should == '06468'
      result.last.search('reference').text.should == '06469'
    end
  end
end
  
