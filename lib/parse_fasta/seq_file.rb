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

  if first_char == ">"
    :fasta
  elsif first_char == "@"
    :fastq
  else
    raise ParseFasta::Error::DataFormatError
  end
end

module ParseFasta
  class SeqFile
    attr_accessor :type

    def initialize fname
      type = check_file fname

      @fname = fname
      @type = type
    end

    def self.open fname
      self.new fname
    end

    def each_record &b
      line_parser = "parse_#{@type}_lines"

      if gzipped? @fname
        each_record_gzipped line_parser, &b
      else
        each_record_non_gzipped line_parser, &b
      end
    end


    private

    def each_record_non_gzipped line_parser, &b
      File.open(@fname) do |f|
        self.send line_parser, f, &b
      end
    end

    def each_record_gzipped line_parser, &b
      File.open(@fname) do |file|
        loop do
          begin
            gz_reader = Zlib::GzipReader.new file

            self.send line_parser, gz_reader, &b

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

    def parse_fasta_line line, header, sequence, &b
      line.chomp!
      len = line.length

      if header.empty? && line.start_with?(">")
        header = line[1, len] # drop the '>'
      elsif line.start_with? ">"
        yield Record.new(header: header.strip, seq: sequence)

        header = line[1, len]
        sequence = ""
      else
        sequence << line
      end

      [header, sequence]
    end

    def parse_fastq_line line, header, seq, desc, qual, count, &b
      line.chomp!

      case count
        when 0
          header = line[1..-1]
        when 1
          seq = line
        when 2
          desc = line[1..-1]
        when 3
          count = -1
          qual = line

          yield Record.new(header: header,
                           seq:    seq,
                           desc:   desc,
                           qual:   qual)
      end

      count += 1

      [header, seq, desc, qual, count]
    end

    def parse_fasta_lines file_reader, &b
      header = ""
      sequence = ""

      file_reader.each_line do |line|
        header, sequence = parse_fasta_line line, header, sequence, &b
      end

      # yield the final seq
      yield Record.new(header: header.strip, seq: sequence)
    end

    def parse_fastq_lines file_reader, &b
      count  = 0
      header = ""
      seq    = ""
      desc   = ""
      qual   = ""

      file_reader.each_line do |line|
        header, seq, desc, qual, count =
            parse_fastq_line line, header, seq, desc, qual, count, &b
      end
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

