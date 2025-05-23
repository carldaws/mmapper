# Mmapper

## Overview
Mmapper is a Ruby gem that provides a high-performance interface for **memory-mapping (mmap) files** using a C extension. This allows efficient read access to large files without loading them into memory. As a proof of concept, a binary search function has been implemented to quickly find lines that match a given prefix.

For testing purposes, the ICANN .com zone file (24.39gb, over 400 million lines) was loaded with Mmapper and the average time to perform a binary search for a given string was ~0.2ms (n=1000), see `benchmark_mmapper.rb`.

## Features
- **Memory-maps large files** for fast, low-memory access.
- **Supports multiple mmap instances** at the same time.
- **Binary search** for finding lines that start with a given prefix.

## Installation

```sh
bundle add mmapper
```

## Usage

### Loading a File
To mmap a file, use `Mmapper::File.new(path)`, which returns an instance:

```ruby
require "mmapper"

mmap = Mmapper::File.new("/path/to/file.txt")
```

### Searching for a Matching Line
The `find_matching_line` method performs a **binary search** for a line that starts with the given prefix:

```ruby
result = mmap.find_matching_line("example")
puts result.nil? ? "Not found" : "Found: #{result}"
```

### Working with Multiple Files
Each mmap instance is independent, allowing you to search different files simultaneously:

```ruby
m1 = Mmapper::File.new("file1.txt")
m2 = Mmapper::File.new("file2.txt")

puts m1.find_matching_line("something")
puts m2.find_matching_line("another")
```

## Running Tests
There's a small test script:

```sh
ruby test_mmapper.rb
```

## License
This project is licensed under the MIT License.

