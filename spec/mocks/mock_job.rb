class MockJob                             
  include RemoteJobs

  @@jobs = []
    
  attr_reader :attributes, :reference
  attr_writer :attributes
  
  def initialize(attributes)
    @reference = attributes[:reference]
    @attributes = attributes
  end

  def self.reset
    @@jobs = []
  end

  # Provided by activerecord or to be included in the module?
  def update_attributes(attributes)
    @@jobs.first.attributes = attributes
  end

  def self.find_by_reference(id)
    referenced_job = nil
    @@jobs.each {|job| referenced_job = job if job.reference == id }
    referenced_job
  end
  
  # Based loosely on activerecord
  def self.find
    @@jobs
  end

  def self.create(attributes)
    @@jobs << self.new(attributes)
  end                                 
end
