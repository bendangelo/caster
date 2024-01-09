module Pipe
  module Utils
    def self.unescape(text : String) : String
      # Pre-reserve a byte-aware required capacity as to avoid heap resizes
      # (30% performance gain relative to initializing this with a zero-capacity)
      String.build(text.bytesize) do |unescaped|
        index = 0

        while (character = text[index]?)

          if character == '\\'
            # Found escaped character

            # skip over next character
            index += 1

            case text[index]?
            when 'n'
              unescaped << '\n'
            when '"'
              unescaped << '"'
            else
              unescaped << character
            end
          else
            unescaped << character
          end

          index += 1
        end
      end

    end
  end
end
