require "mmapper"
require "tempfile"

# Create two temporary files with different content
tempfile1 = Tempfile.new("mmap_test1")
tempfile1.write("alpha\nbravo\ncharlie\ndelta\necho\n")
tempfile1.flush

tempfile2 = Tempfile.new("mmap_test2")
tempfile2.write("foxtrot\ngolf\nhotel\nindia\njuliet\n")
tempfile2.flush

puts "Loading multiple files..."
mmap1 = Mmapper.load_file(tempfile1.path)
mmap2 = Mmapper.load_file(tempfile2.path)

# Define test cases to check separate searches per file
test_cases = [
  { mmap: mmap1, query: "alpha", expected: true, description: "alpha should be found in file1" },
  { mmap: mmap1, query: "foxtrot", expected: false, description: "foxtrot should NOT be found in file1" },
  { mmap: mmap2, query: "golf", expected: true, description: "golf should be found in file2" },
  { mmap: mmap2, query: "bravo", expected: false, description: "bravo should NOT be found in file2" },
  { mmap: mmap1, query: "charlie", expected: true, description: "charlie should be found in file1" },
  { mmap: mmap2, query: "juliet", expected: true, description: "juliet should be found in file2" },
  { mmap: mmap2, query: "delta", expected: false, description: "delta should NOT be found in file2" }
]

# Run tests
puts "\nRunning multi-file tests:"
test_cases.each do |tc|
  result = tc[:mmap].find_matching_line(tc[:query])
  found = !result.nil?
  status = found == tc[:expected] ? "✅" : "❌"
  puts "#{status} #{tc[:description]} (query: #{tc[:query]}, expected: #{tc[:expected]}, got: #{found})"
end

# Clean up
tempfile1.close
tempfile1.unlink
tempfile2.close
tempfile2.unlink

puts "\nMulti-file test complete!"
