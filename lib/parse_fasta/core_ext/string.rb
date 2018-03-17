module ParseFasta
  module CoreExt
    module String

      # Removes all gap chars from the string.
      #
      # @example Remove all '-' from string
      #   # First inclued the methods
      #   String.include ParseFasta::CoreExt::String
      #
      #   # The default gap char is '-'
      #   "--A-C-t-g".remove_gaps #=> "ACtg"
      #
      # @example Change the gap character to 'n'
      #   # First inclued the methods
      #   String.include ParseFasta::CoreExt::String
      #
      #   "-N-nACTG".remove_gaps "N" #=> "--nACTG"
      #
      # @example Passing multiple gap chars
      #   # First inclued the methods
      #   String.include ParseFasta::CoreExt::String
      #
      #   ".A----C_t~~~~g^G3".remove_gaps '^._-~3' #=> "ACtgG"
      #
      # @param gap_char [String] the character(s) to treat as a gap
      #
      # @return [String] a string with all instances of
      #   gap_char_removed
      def remove_gaps gap_char="-"

        if gap_char.length > 1
          if gap_char.include? "^"
            gap_char.sub! '^', '\\^'
          end

          if gap_char.include? "-"
            gap_char.sub! '-', '\\-'
          end
        end

        self.tr gap_char, ""
      end
    end
  end
end
