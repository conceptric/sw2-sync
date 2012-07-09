module JobMacros

  def stub_remote_jobs(how_many)
    jobs = {}
    how_many.times do |i| 
      jobs["#{i+1}"]= { reference: "#{i+1}", title: "job title #{i+1}" }
    end
    MockJob.stub(:find_remote_jobs).
      and_return(jobs)      
  end
  
  def local_jobs_fixtures(how_many_sync, how_many_static=0)
    jobs = []
    how_many_sync.times do |i| 
      MockJob.create({ reference: "#{i+1}", title: "job title #{i+2}" })
    end
    how_many_static.times do |i| 
      MockJob.create({ reference: nil, title: "static job title #{i+1}" })
    end
  end

end