# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "sw2-sync"
  s.version     = "0.0.3"
  s.authors     = ["James Whinfrey"]
  s.email       = ["james@conceptric.co.uk"]
  s.homepage    = ""
  s.summary     = %q{Library to sync jobs in Rails apps with SW2 XML}
  s.description = %q{This is a project aimed at providing synchronisation between Jobs on a local Rails application and those provided by a remote XML feed from SW2 software.}

  s.rubyforge_project = "sw2-sync"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency('rspec')
  s.add_dependency('rake')
  s.add_dependency('nokogiri')
end