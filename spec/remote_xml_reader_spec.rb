require File.join(File.dirname(__FILE__), *%w[.. lib remote_xml_reader.rb])

describe RemoteXmlReader do
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
  
