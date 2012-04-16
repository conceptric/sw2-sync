require 'rspec'
require 'nori'
require 'nokogiri'

module XmlStreamParser
  def XmlStreamParser.fetch(remote_url)
    open(remote_url).read
  end
end  

class RemoteJobsList 
  include XmlStreamParser
  
  def initialize(remote_url)
    @xml = XmlStreamParser.fetch(remote_url)
    config_nori
  end
  
  def raw
    @xml
  end
  
  def to_hash
    attributes = [] 
    Nokogiri::XML(raw).search('jobs').children.each do |job|
      Nori.parse(job.to_xml).each {|key, value| attributes << value }
    end
    attributes
  end    

  private 
  def config_nori
    Nori.configure do |config|
      config.convert_tags_to { |tag| tag.to_sym }
    end        
  end      
end

describe XmlStreamParser do
  let(:test_url) { 'http://www.job-tv.co.uk/XML.asp' }
  
  describe ".fetch" do
    it "opens a remote url and reads the contents" do
      subject.should_receive(:open).once.with(test_url).
        and_return(StringIO.new(
        File.read(File.join(File.dirname(__FILE__), 
          *%w[fixtures sw2_simple_example.xml]))))
      subject.fetch(test_url)  
    end    
  end  
end
  
describe RemoteJobsList do
  
  let(:test_url) { 'http://www.job-tv.co.uk/XML.asp' }
    
  describe "a very simple remote feed" do
    let(:simple_test_target) { File.join(File.dirname(__FILE__), 
      *%w[fixtures sw2_simple_example.xml]) }
  
    before(:each) do
      XmlStreamParser.should_receive(:open).once.and_return(StringIO.new(
        File.read(File.join(simple_test_target))))
      @job_list = RemoteJobsList.new(test_url)
    end                                           
  
    describe ".new" do    
      it "creates a new instance" do
        @job_list.should be_instance_of(RemoteJobsList)
      end
    end  

    describe ".raw" do
      it "returns an xml document" do
        @job_list.raw.should include('?xml version="1.0" encoding="ISO-8859-1"?')
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
    let(:hard_test_target) { File.join(File.dirname(__FILE__), 
      *%w[fixtures sw2_harder_example.xml]) } 

    before(:each) do
      XmlStreamParser.should_receive(:open).once.and_return(StringIO.new(
        File.read(File.join(hard_test_target))))        
      @multi_job_list = RemoteJobsList.new(test_url)
    end

    describe ".raw" do
      it "returns an xml document" do
        @multi_job_list.raw.should include('?xml version="1.0" encoding="ISO-8859-1"?')
      end     
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
