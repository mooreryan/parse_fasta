class FastaFile < File
  def each_record
    self.each("\n>") do |line|
      header, sequence = parse_line(line)
      yield header.strip, Sequence.new(sequence)
    end
  end

  private
  def parse_line(line)
    line.chomp.split("\n", 2).map { |s| s.gsub(/\n|>/, '') }
  end
end

