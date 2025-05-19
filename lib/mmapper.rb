require 'mmapper/mmapper'

module Mmapper
  class File
    def find_matching_line(prefix)
      low = 0
      high = size

      while low < high
        mid = (low + high) / 2
        line_start = find_line_start(mid)
        line = read_line_at(line_start)

        return nil if line.nil?

        if line < prefix
          low = mid + 1
        else
          high = mid
        end

      end

      final_line_start = find_line_start(low)
      line = read_line_at(final_line_start)

      if line&.start_with?(prefix)
        line
      else
        nil
      end
    end

    private

    def find_line_start(pos)
      pos = [pos, size - 1].min
      pos -= 1 while pos > 0 && read(pos, 1) != "\n"
      pos += 1 if pos != 0
      pos
    end

    def read_line_at(pos)
      buf = +''
      chunk_size = 64
      while pos < size
        safe_len = [size - pos, chunk_size].min
        chunk = read(pos, safe_len)
        newline_idx = chunk.index("\n")
        if newline_idx
          buf << chunk[0..newline_idx]
          break
        else
          buf << chunk
          pos += chunk_size
        end
      end
      buf.empty? ? nil : buf.chomp
    end
  end
end
