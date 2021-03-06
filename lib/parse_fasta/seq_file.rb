require "zlib"

module ParseFasta
  class SeqFile
    # @!attribute type
    #   @return [Symbol] the type of the SeqFile (:fasta or :fastq)
    attr_accessor :type

    # @param fname [String] the name of the fastA or fastQ file to
    #   parse
    # @param type [Symbol] whether the file is :fasta or :fastq
    # @param check_fasta_seq [Bool] keyword arg for whether to check
    #   for '>' in the sequence of fastA files.
    #
    # @raise [ParseFasta::Error::FileNotFoundError] if the file is not
    #   found
    # @raise [ParseFasta::Error::DataFormatError] if the file doesn't
    #   start with a '>' or a '@'
    def initialize fname, args = {}
      type = check_file fname

      @check_fasta_seq = args.fetch :check_fasta_seq, true
      @fname = fname
      @type = type
    end

    # An alias for SeqFile.new
    #
    # @return [SeqFile] a SeqFile object
    def self.open fname, args = {}
      self.new fname, args
    end

    # Analagous to IO#each_line, SeqFile#each_record is used to go
    # through a fastA or fastQ file record by record. It will accept
    # gzipped files as well.
    #
    # If the input is a fastA file, then the record that is yielded
    # will have the desc and qual instance variables be nil. If it is
    # a fastQ record then those instance variables will not be nil.
    #
    # @example Parsing a fastA file
    #   ParseFasta::SeqFile.open("seqs.fa").each_record do |rec|
    #     puts [rec.header, rec.seq].join "\t"
    #
    #     rec.desc.nil? #=> true
    #     rec.qual.nil? #=> true
    #   end
    # @example Parsing a gzipped fastQ file
    #   ParseFasta::SeqFile.open("seqs.fq.gz").each_record do |rec|
    #     puts [rec.header, rec.seq, rec.desc, rec.qual].join "\t"
    #   end
    #
    # @yieldparam record [ParseFasta::Record] A Record object with all
    #   the info of the record
    #
    # @raise [ParseFasta::Error::SequenceFormatError] if a fastA file
    #   contains a record with a '>' character in the header, and the
    #   SeqFile object was not initialized with check_fasta_seq: false
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
      File.open(@fname, "rt") do |f|
        self.send line_parser, f, &b
      end
    end

    def each_record_gzipped line_parser, &b
      File.open(@fname, "rt") do |file|
        loop do
          begin
            gz_reader = Zlib::GzipReader.new file

            self.send line_parser, gz_reader, &b

            # check if there are any more blobs to read
            if (unused = gz_reader.unused)
              # rewind to the start of the last blob
              file.seek -unused.length, IO::SEEK_END
            else
              # there are no more blobs to read
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
        yield Record.new(header: header.strip,
                         seq: sequence,
                         check_fasta_seq: @check_fasta_seq)

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
        else
          raise ParseFasta::Error::ParseFastaError,
                "Something went wrong in parse_fastq_line"
      end

      count += 1

      [header, seq, desc, qual, count]
    end

    def parse_fasta_lines file_reader, &b
      header = ""
      sequence = ""

      line_reader = which_line_reader file_reader
      file_reader.send(*line_reader) do |line|
        header, sequence = parse_fasta_line line, header, sequence, &b
      end

      # yield the final seq
      yield Record.new(header: header.strip,
                       seq: sequence,
                       check_fasta_seq: @check_fasta_seq)
    end

    def parse_fastq_lines file_reader, &b
      count  = 0
      header = ""
      seq    = ""
      desc   = ""
      qual   = ""

      line_reader = which_line_reader file_reader
      file_reader.send(*line_reader) do |line|
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

    # The Zlib::GzipReader can't handle files where the line separator
    # is \r. This could all be avoided by using IO.popen("gzip -cd
    # #{fname}", "rt"), but will gzip always be available?
    def which_line_reader file_reader
      line_reader = [:each_line]
      # a valid fasta file must have at least two lines, the header
      # and the sequence
      begin
        enum = file_reader.each_line
        # if this was ruby v2.3, then we could just call .size on enum
        2.times do
          enum.next
        end
      rescue StopIteration
        # Zlib::GzipReader can handle \n and \r\n, but not \r, so if
        # we get here, the file has \r only for line endings
        line_reader = [:each, "\r"]
      ensure
        file_reader.rewind
      end

      line_reader
    end

    # Get the first char of the file whether it is gzip'd or not.  No
    # need to rewind the stream afterwards.
    def get_first_char fname
      if File.exists? fname
        begin
          f = Zlib::GzipReader.open fname
        rescue Zlib::GzipFile::Error
          f = File.open fname
        end


        begin
          first_char = f.each.peek[0]

          return first_char
        ensure
          f.close
        end
      else
        raise ParseFasta::Error::FileNotFoundError,
              "No such file or directory -- #{fname}"
      end
    end

    def check_file fname
      first_char = get_first_char fname

      if first_char == ">"
        :fasta
      elsif first_char == "@"
        :fastq
      else
        raise ParseFasta::Error::DataFormatError,
              "The file does not look like fastA or fastQ " +
                  "-- #{fname}"
      end
    end
  end
end
