PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), *%w[..]))
require File.join(PROJECT_ROOT, *%w[lib sw2-sync.rb])
require File.join(PROJECT_ROOT, *%w[spec mocks mock_job.rb])

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(PROJECT_ROOT, "spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.include JobMacros
end
