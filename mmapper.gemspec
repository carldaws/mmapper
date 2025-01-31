Gem::Specification.new do |spec|
  spec.name          = "mmapper"
  spec.version       = "0.1.0"
  spec.authors       = ["Carl Dawson"]
  spec.email         = ["email@carldaws.com"]
  spec.summary       = "Mmap-ed files using Go and FFI."
  spec.description   = "Wraps a Go extension for mmap-ing files."
  spec.homepage      = "https://github.com/carldaws/mmapper"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb", "ext/mmap.go", "README.md"]
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/extconf.rb"]
end
