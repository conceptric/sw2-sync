require File.join(File.dirname(__FILE__), *%w[.. lib remote_job_list.rb])

describe RemoteJobsList do

  describe ".new" do    
    it "creates a new instance" do
      RemoteJobsList.new('simple').should be_instance_of(RemoteJobsList)
    end
  end  
 
end
