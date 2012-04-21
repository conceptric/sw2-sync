class MockJob                             
  include RemoteJobs

  @@jobs = []
    
  attr_reader :attributes
  
  def initialize(attributes)
    @attributes = attributes
  end

  def self.find
    @@jobs
  end
  
  def self.create(attributes)
    @@jobs << self.new(attributes)
  end    

  def self.reset
    @@jobs = []
  end
end
