module Pipe
  module Utils
    def self.unescape(text : String) : String
      String.build(text.bytesize) do |unescaped|
        index = 0

        while (character = text[index]?)

          if character == '\\'
            # Found escaped character

            # skip over next character
            # index += 1

            case text[index + 1]?
            when 'n'
              unescaped << '\n'
            index += 1
            # when '"'
            #   unescaped << '"'
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
