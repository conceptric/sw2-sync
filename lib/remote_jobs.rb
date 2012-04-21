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
      find_remote_jobs(remote_url).each do |job_ref, job_attr|
        create_or_update(job_ref, job_attr)
      end      
    end    
    
    def create_or_update(reference, attributes)
      jobs = self.find_by_reference(reference)
      if jobs.empty? then
        self.create(attributes)
      elsif jobs.size == 1
        jobs.first.update_attributes(attributes)
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