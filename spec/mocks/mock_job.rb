class MockJob
  include RemoteJobs

  # Represents the Jobs in the application database
  @@jobs = []
  @@default_attributes = []

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

  def self.set_attributes_list(attributes_list)
    @@default_attributes = attributes_list
  end

  # Need to be provided in the Model (include in the module?)
  def unpublish
    self.published = false
  end

  def self.find_remotely_referenced_jobs
    remote_jobs = []
    @@jobs.each {|job| remote_jobs << job unless job.reference == nil }
    remote_jobs
  end

  # Methods that are provided by ActiveRecord
  def self.find
    @@jobs
  end

  def self.find_by_reference(id)
    referenced_job = nil
    @@jobs.each {|job| referenced_job = job if job.reference == id }
    referenced_job
  end

  def self.create(attributes)
    @@jobs << self.new(attributes)
  end

  def update_attributes(attributes)
    @@jobs.first.attributes = attributes
  end

  def self._accessible_attributes
    {
      :default => @@default_attributes
    }
  end

end
