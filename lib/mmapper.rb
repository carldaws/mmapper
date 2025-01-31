require 'ffi'

module Mmapper
  extend FFI::Library

  LIB_DIR = File.expand_path("../../ext", __FILE__)

  LIB_NAME =
    case RUBY_PLATFORM
    when /darwin/ then "libmmapper.dylib"
    when /mingw|mswin/ then "mmapper.dll"
    else "libmmapper.so"
    end

  LIB_PATH = File.join(LIB_DIR, LIB_NAME)

  unless File.exist?(LIB_PATH)
    Dir.chdir(LIB_DIR) do
      puts "Compiling Go shared library for #{RUBY_PLATFORM}..."
      system("go build -o #{LIB_NAME} -buildmode=c-shared .") || raise("Go build failed")
    end
  end

  ffi_lib LIB_PATH

  attach_function :create_mmapper, :CreateMmapper, [:string], :int
  attach_function :find_matching_line, :FindMatchingLine, [:int, :string], :string

  class Instance
    def initialize(filename)
      @mmapper_id = Mmapper.create_mmapper(filename)
      raise "Failed to load file: #{filename}" if @mmapper_id < 0
    end

    def find_matching_line(prefix)
      result = Mmapper.find_matching_line(@mmapper_id, prefix)
      return nil if result.nil? || result.empty?
      result
    end
  end

  def self.load_file(filename)
    Instance.new(filename)
  end
end
