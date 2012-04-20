module RemoteJobs
  module ClassMethods
    def find_jobs_to_sync
      self.find_with_reference
    end    
  end
  
  module InstanceMethods
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end