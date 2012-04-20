require 'remote_xml_reader'

module RemoteJobs
  module ClassMethods
    def find_jobs_to_sync(&block)
      yield
    end    
    
    def find_remote_jobs(remote_url)
      RemoteXmlReader.new(remote_url).child_nodes_to_hash('jobs')
    end
  end
  
  module InstanceMethods
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end