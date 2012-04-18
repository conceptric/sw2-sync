require File.join(File.dirname(__FILE__), *%w[.. lib remote_xml_reader.rb])
FIXTURES = File.join(File.dirname(__FILE__), *%w[fixtures])

def fixture_stream_helper(filename)
  StringIO.new(File.read(File.join(FIXTURES, filename)))
end

describe RemoteXmlReader do

  describe "RemoteXmlReader.open" do
    
    it "opens a remote url" do
      test_url = 'http://www.example.com/example.xml'

      RemoteXmlReader.should_receive(:open).
      once.
      with(test_url).
      and_return(
        fixture_stream_helper('single_node.xml'))

      RemoteXmlReader.open(test_url).read.
          should == open(FIXTURES + '/single_node.xml').read  
    end
        
  end  

  describe ".new" do      
    
    before(:each) do  
      xml_file = open(FIXTURES + '/single_node.xml')
      RemoteXmlReader.stub(:open).and_return(xml_file)      
    end

    it "creates a new instance" do
      RemoteXmlReader.new('remote_url').
        should be_instance_of(RemoteXmlReader)      
    end        

    it "that contains the target xml" do
      xml_file = open(FIXTURES + '/single_node.xml')
      RemoteXmlReader.new('remote_url').read.
        should == xml_file.read
    end
    
  end

  describe ".extract_named_nodes" do
    
    before(:each) do
      RemoteXmlReader.stub(:open).and_return(
        open(FIXTURES + '/twin_node.xml'))      
      remote_xml_reader = RemoteXmlReader.new('remote_url')
      @result = remote_xml_reader.extract_named_nodes('item')
    end
  
    it "returns an array containing matching nodes" do
      @result.size.should == 2
    end                                                        
    
    it "each of these data nodes are Nokogiri elements" do
      @result.each do |item|
        item.should be_instance_of(Nokogiri::XML::Element)
      end
    end
  
    it "each element contains the correct amount of data" do
      @result.each do |item|
        item.children.count.should == 5
      end
    end
  
    it "each element contains the correct data" do
      @result.each do |item|
        item.node_name == "item"
        item.first_element_child.node_name.should == 'child1'
        item.last_element_child.node_name.should == 'child2'
      end
    end
    
  end 
  
  describe ".named_nodes_to_hash" do
    
    def setup(actual_xml_file)
      RemoteXmlReader.stub(:open).and_return(
        open(FIXTURES + '/' + actual_xml_file))      
      remote_reader = RemoteXmlReader.new("remote_url")
      remote_reader.named_nodes_to_hash("item")
    end

    it "converts the children of a named node to a hash" do 
      result = setup('single_node.xml')
      result.should == [{child1: "value1", child2: "value2"}]
    end

    it "converts the children of two named node to a hashes" do 
      result = setup('twin_node.xml')
      result.should == [
        {child1: "value1", child2: "value2"},
        {child1: "value1", child2: "value2"}]
    end

    it "the hash is not recursive" do 
      result = setup('complex_twin_node.xml')
      result.should == [
        {child1: "value1", child2: "value2"},
        {child1: "value1", child2: "CDATA is included\nwith special characters"},
        {child1: "value1", child2: "value2"}]
    end                           
    
  end
  
end
  
