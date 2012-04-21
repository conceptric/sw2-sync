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
        self.create(job_attr)
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