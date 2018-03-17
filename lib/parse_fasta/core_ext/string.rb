module ParseFasta
  module CoreExt
    module String

      # Removes all gap chars from the string.
      #
      # @example Remove all '-' from string
      #   # First inclued the methods
      #   String.include ParseFasta::CoreExt::String
      #
      #   "--A-C-t-g".remove_gaps #=> "ACtg"
      #
      # @example Change the gap character to 'n'
      #   # First inclued the methods
      #   String.include ParseFasta::CoreExt::String
      #
      #   "-N-nACTG".remove_gaps "N" #=> "--nACTG"
      #
      # @param gap_char [String] the character to treat as a gap
      #
      # @return [String] a string with all instances of
      #   gap_char_removed
      def remove_gaps gap_char="-"
        self.tr gap_char, ""
      end
    end
  end
end
