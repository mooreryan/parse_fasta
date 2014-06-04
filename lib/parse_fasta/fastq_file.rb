class FastqFile < File
  def each_record
    count = 0
    header = ''
    sequence = ''
    description = ''
    quality = ''
    
    self.each_line do |line|
      line.chomp!

      case count % 4
      when 0
        header = line.sub(/^@/, '')
      when 1
        sequence = line
      when 2
        description = line.sub(/^\+/, '')
      when 3
        quality = line
        yield(header, sequence, description, quality)
      end
      
      count += 1
    end
  end
end
