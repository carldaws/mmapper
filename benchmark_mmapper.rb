require 'mmapper'
require 'benchmark'

mmap = Mmapper::File.new('com.txt')

# Define test cases (expected: true if found, false if not)
test_cases = {
  'google' => true,
  'amazon' => true,
  'zillow' => true,
  '00000129210aaaaaaa' => false,
  'zzzz2030401131zzz' => false,
  'ranaskdmks299jdjaddomxyz' => false
}

ITERATIONS = 1000

puts "\nBenchmarking Mmapper Search Performance"
Benchmark.bm(25) do |bm|
  test_cases.each do |query, expected|
    bm.report("#{query} (#{expected ? 'found' : 'not found'})") do
      ITERATIONS.times do
        result = mmap.find_matching_line(query)
        found = !result.nil?

        raise "❌ Unexpected result for #{query}: Expected #{expected}, got #{found}" if found != expected
      end
    end
  end
end

puts "\n✅ Benchmark complete! All results validated."
