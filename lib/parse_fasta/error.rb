module ParseFasta
  # Contains the Error classes that ParseFasta API will raise
  module Error

    # All ParseFasta errors inherit from ParseFastaError
    class ParseFastaError < StandardError
    end

    # Raised when a method has a bad argument
    class ArgumentError < ParseFastaError
    end

    # Raised when the input file doesn't look like fastA or fastQ
    class DataFormatError < ParseFastaError
    end

    # Raised when the file is not found
    class FileNotFoundError < ParseFastaError
    end

    # Raised when fastA sequences have a '>' in them
    class SequenceFormatError < ParseFastaError
    end
  end
end
