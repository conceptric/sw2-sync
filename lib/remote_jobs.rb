module RemoteJobs
  module ClassMethods
    def find_jobs_to_sync(&block)
      yield
    end    
    
    def find_remote_jobs(remote_url)                             
      jobs = {}
      Remote::Xml::Reader.new(remote_url).child_nodes_to_hash('jobs').each do |job|
        clean_job = mass_assignment_cleanup(job)
        jobs[clean_job[:reference]] = clean_job unless clean_job[:reference] == ''
      end                        
      jobs
    end
    
    def sync_with(remote_url)
      remote_jobs = find_remote_jobs(remote_url)
      
      find_remotely_referenced_jobs.each do |job|
        job.unpublish unless remote_jobs.has_key? job.reference
      end                                                   
      
      remote_jobs.each do |job_ref, job_attr|
        create_or_update(job_ref, job_attr)
      end      
    end    
    
    private
    def create_or_update(reference, attributes)
      job = self.find_by_reference(reference)
      begin
        if job == nil then
          self.create(attributes)
        else
          job.update_attributes(attributes)
          job.published = true
        end      
      rescue StandardError        
      end
    end 
    
    def mass_assignment_cleanup(job)
      job.each_key do |key| 
        job.delete_if do |key, value|   
          !self._accessible_attributes[:default].include?(key.to_s)
        end
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