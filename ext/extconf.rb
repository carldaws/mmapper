require 'mkmf'
require 'fileutils'

LIB_DIR = File.expand_path(File.dirname(__FILE__))

# Detect OS and set correct library name
LIB_NAME =
  case RUBY_PLATFORM
  when /darwin/ then "libmmapper.dylib"
  when /mingw|mswin/ then "mmapper.dll"
  else "libmmapper.so"
  end

LIB_PATH = File.join(LIB_DIR, LIB_NAME)

# Ensure Go module is initialized
Dir.chdir(LIB_DIR) do
  unless File.exist?("go.mod")
    puts "Initializing Go module..."
    system("go mod init mmapper") || raise("Failed to initialize Go module")
  end

  puts "Building Go shared library for #{RUBY_PLATFORM}..."
  unless system("go build -o #{LIB_NAME} -buildmode=c-shared .")
    raise "Go build failed!"
  end
end

create_makefile('mmapper')
