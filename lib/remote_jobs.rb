require 'remote_xml_reader'

module RemoteJobs
  module ClassMethods
    def find_jobs_to_sync(&block)
      yield
    end    
    
    def find_remote_jobs(remote_url)
      RemoteXmlReader.new(remote_url).child_nodes_to_hash('jobs')
    end
    
    def sync_with(remote_url, &block)
      remote_jobs = find_remote_jobs(remote_url)
      
      find_jobs_with_reference.each do |job|
        job.unpublish unless remote_jobs.has_key? job.reference
      end                                                   
      
      remote_jobs.each do |job_ref, job_attr|
        create_or_update(job_ref, job_attr)
      end      
    end    
    
    def create_or_update(reference, attributes)
      job = self.find_by_reference(reference)
      if job == nil then
        self.create(attributes)
      else
        job.update_attributes(attributes)
      end      
    end
  end
  
  module InstanceMethods
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end