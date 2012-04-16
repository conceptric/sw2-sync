require 'rspec'
require 'open-uri'

module JobsParser
  def JobsParser.fetch(url)
    open(url)
  end 
                         
  def JobsParser.jobs
    [{reference: "",
      title: "",
      category: "",
      jobtype: "",
      startdate: "",
      enddate: "",
      duration: "",
      pubDate: "",
      salary: "",
      location: "",
      joboftheweek: "",
      contactname: "",
      contactemail: "",
      description: ""}]
  end
end

describe JobsParser do

  describe "A simple single job stream" do
    let(:test_url) { 'http://www.job-tv.co.uk/XML.asp' }
    
    it "opens the remote url and reads the xml when initialised" do
      # and_return(StringIO.new(
      # File.read(File.join(File.dirname(__FILE__), 
      #   *%w[fixtures sw2_simple_example.xml]))))      
      JobsParser.should_receive(:open).once.with(test_url).
        and_return('done')
      JobsParser::fetch(test_url).should == 'done'      
    end

    it "returns a hash for each job" do
      subject.jobs.first.should be_instance_of(Hash)
    end 
  
    it "that contains all the api attributes" do
      subject.jobs.first[:reference].should be_true
      subject.jobs.first[:title].should be_true
      subject.jobs.first[:category].should be_true
      subject.jobs.first[:jobtype].should be_true
      subject.jobs.first[:startdate].should be_true
      subject.jobs.first[:enddate].should be_true
      subject.jobs.first[:duration].should be_true
      subject.jobs.first[:pubDate].should be_true
      subject.jobs.first[:salary].should be_true
      subject.jobs.first[:location].should be_true
      subject.jobs.first[:joboftheweek].should be_true
      subject.jobs.first[:contactname].should be_true
      subject.jobs.first[:contactemail].should be_true
      subject.jobs.first[:description].should be_true
    end

    it "has just one job" do
      subject.jobs.count.should == 1
    end  
  end
  
end
