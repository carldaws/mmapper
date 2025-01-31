Gem::Specification.new do |spec|
  spec.name          = "mmapper"
  spec.version       = "1.0.0"
  spec.authors       = ["Carl Dawson"]
  spec.email         = ["email@carldaws.com"]
  spec.summary       = "Mmap-ed files using Go and FFI."
  spec.description   = "Wraps a Go extension for mmap-ing files."
  spec.homepage      = "https://github.com/carldaws/mmapper"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb", "ext/mmap.go", "README.md"]
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/extconf.rb"]
  spec.add_runtime_dependency "ffi", "~> 1.15"
end
