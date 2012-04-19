require "rexml/document"

require File.join(File.dirname(__FILE__), *%w[.. lib remote_xml_reader.rb])
FIXTURES = File.join(File.dirname(__FILE__), *%w[fixtures])

def fixture_stream_helper(filename)
  StringIO.new(File.read(File.join(FIXTURES, filename)))
end

describe RemoteXmlReader do

  describe "RemoteXmlReader.open" do
    
    context "a remote url that exists" do
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
      
      it "opens the remote url to a blank document" do
        RemoteXmlReader.should_receive(:open).
        and_return(
          fixture_stream_helper('blank_document.xml'))

        expect { RemoteXmlReader.open('blank') }.
          should_not raise_error
      end
    end

    context "a remote url that does not exist" do
      it "raises an exception with a message about the invalid url" do
        expect { RemoteXmlReader.open('invalid') }.
          to raise_error(ArgumentError, "This URI is invalid")
      end

      it "raises an exception with a message about a nil url" do
        expect { RemoteXmlReader.open(nil) }.
          to raise_error(ArgumentError, "A URI is required")
      end

      it "raises an exception with a message about a blank url" do
        expect { RemoteXmlReader.open('') }.
          to raise_error(ArgumentError, "This URI is invalid")
      end
    end
    
  end  

  describe ".new" do      
    
    def xml_stub(filename)
      xml_file = open(FIXTURES + '/' + filename)
      RemoteXmlReader.stub(:open).and_return(xml_file)            
    end
    
    shared_examples "a new XML Reader" do |example_xml_file|      
      it "creates a new instance" do
        xml_stub(example_xml_file)
        RemoteXmlReader.new('remote_url').
          should be_instance_of(RemoteXmlReader)      
      end        

      it "that contains the target xml" do
        xml_stub(example_xml_file)
        xml_file = open(FIXTURES + '/' + example_xml_file)
        RemoteXmlReader.new('remote_url').read.
          should == xml_file.read
      end
    end
    
    context "given a remote url to valid xml" do
      include_examples "a new XML Reader", 'single_node.xml'
    end
    
    context "given a remote url to empty xml" do
      include_examples "a new XML Reader", 'blank_document.xml'
    end

    context "given a remote url to an empty file" do
      include_examples "a new XML Reader", 'empty.xml'
    end
  end

  describe ".extract_named_nodes" do

    def xml_stub(filename)
      xml_file = open(FIXTURES + '/' + filename)
      RemoteXmlReader.stub(:open).and_return(xml_file)            
    end

    def remote_reader_setup(filename)
      xml_stub(filename)
      remote_xml_reader = RemoteXmlReader.new('remote_url')
      remote_xml_reader.extract_named_nodes('item')
    end
    
    context "given a file with valid xml" do
      before(:each) do
        @result = remote_reader_setup('/twin_node.xml')
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
      result = setup('complex_node.xml')
      result.should == [
        {child1: "value1", child2: "value2"},
        {child1: "value1", child2: "CDATA is included\nwith special characters"},
        {item: "This is an attribute, not the named node", 
         child1: "value1", child2: "value2"}, {}]
    end                           
    
  end
  
end
  
