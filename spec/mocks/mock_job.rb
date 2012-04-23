class MockJob                             
  include RemoteJobs

  @@jobs = []
    
  attr_reader :attributes, :reference, :published
  attr_writer :attributes, :published
  
  def initialize(attributes)
    @reference = attributes[:reference]
    @published = true
    @attributes = attributes
  end

  def self.reset
    @@jobs = []
  end

  # Provided by activerecord or to be included in the module?
  def update_attributes(attributes)
    @@jobs.first.attributes = attributes
  end

  def unpublish
    self.published = false
  end

  def self.find_remotely_referenced_jobs
    remote_jobs = []
    @@jobs.each {|job| remote_jobs << job unless job.reference == nil }
    remote_jobs    
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

  def self._accessible_attributes
    {:default => ["reference", "contactemail", "contactname", "description", "jobtype", "location", "salary", "title"]}
  end
  
end
