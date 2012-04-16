require 'rspec'

class JobsParser
  attr_reader :url
  def initialize(url)
    @url = url
  end 
                         
  def count
    2                 
  end
  
  
end

describe JobsParser.new("./fixtures/sw2_simple_example.xml") do
  its(:url) { should == "./fixtures/sw2_simple_example.xml"}
  its(:count) { should == 2 }
end