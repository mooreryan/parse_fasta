# Copyright 2014 - 2016 Ryan Moore
# Contact: moorer@udel.edu
#
# This file is part of parse_fasta.
#
# parse_fasta is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# parse_fasta is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with parse_fasta.  If not, see <http://www.gnu.org/licenses/>.

def get_first_char fname
  begin
    f = Zlib::GzipReader.open fname
  rescue Zlib::GzipFile::Error => e
    f = File.open fname
  ensure
    first_char = f.each_char.peek[0]

    f.close

    return first_char
  end
end

def check_file fname
  first_char = get_first_char fname

  unless first_char == ">" || first_char == "@"
    raise ParseFasta::Error::DataFormatError
  end
end

module ParseFasta
  class SeqFile
    def initialize fname
      @fname = fname
    end

    def self.open fname
      check_file fname

      self.new fname
    end

    def each_record &b
      if gzipped? @fname
        each_record_gzipped &b
      else
        each_record_non_gzipped &b
      end
    end

    private

    def each_record_non_gzipped &b
      File.open(@fname) do |f|
        parse_lines f, &b
      end
    end

    def each_record_gzipped &b
      File.open(@fname) do |file|
        loop do
          begin
            gz_reader = Zlib::GzipReader.new file

            parse_lines gz_reader, &b

            # check if there are any more blobs to read
            if (unused = gz_reader.unused)
              # rewind to the start of the last blob
              file.seek -unused.length, IO::SEEK_END
            else # there are no more blobs to read
              break
            end
          end
        end
      end
    end

    def parse_line line, header, sequence, &b
      line.chomp!
      len = line.length

      if header.empty? && line.start_with?(">")
        header = line[1, len] # drop the '>'
      elsif line.start_with? ">"
        yield Record.new header.strip, sequence

        header = line[1, len]
        sequence = ""
      else
        sequence << line
      end

      [header, sequence]
    end

    def parse_lines file_reader, &b
      header = ""
      sequence = ""

      file_reader.each_line do |line|
        header, sequence = parse_line line, header, sequence, &b
      end

      # yield the final seq
      yield Record.new header.strip, sequence
    end

    def gzipped? fname
      begin
        f = Zlib::GzipReader.open fname
        return true
      rescue Zlib::GzipFile::Error => e
        return false
      ensure
        f.close if f
      end
    end
  end
end

