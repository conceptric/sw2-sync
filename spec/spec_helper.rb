require File.join(File.dirname(__FILE__), *%w[.. lib remote_jobs.rb])
require File.join(File.dirname(__FILE__), *%w[mocks mock_job.rb])

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
