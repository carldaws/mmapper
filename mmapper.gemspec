Gem::Specification.new do |spec|
  spec.name          = 'mmapper'
  spec.version       = '2.0.0'
  spec.authors       = ['Carl Dawson']
  spec.email         = ['email@carldaws.com']
  spec.summary       = 'Mmap-ed files in Ruby using a C native extension'
  spec.description   = 'Wraps a C extension for mmap-ing files.'
  spec.homepage      = 'https://github.com/carldaws/mmapper'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb', 'ext/**/*', 'README.md']
  spec.require_paths = ['lib']
  spec.extensions    = ['ext/extconf.rb']
end
