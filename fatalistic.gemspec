require File.expand_path("../lib/fatalistic", __FILE__)

Gem::Specification.new do |s|
  s.name              = "fatalistic"
  s.version           = Fatalistic::VERSION
  s.authors           = ["Norman Clarke"]
  s.email             = ["norman@njclarke.com"]
  s.homepage          = "http://github.com/bvision/fatalistic"
  s.summary           = "Table-level locking for Active Record"
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test}/*`.split("\n")
  s.require_paths     = ["lib"]

  s.add_development_dependency "minitest"

  s.description = <<-EOM
Active Record provides "optimistic" and "pessimistic" modules for row-level
locking, but provide nothing to do full-table locking. Fatalistic provides this.
EOM
end
