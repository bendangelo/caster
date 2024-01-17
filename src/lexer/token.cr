module Lexer
  alias TermHash = UInt32

  enum Lang
    None
    Eng
    Cmd
    Jpn
  end

  enum TokenMode
    HintedCleanup
    NormalizeAndCleanup
    NormalizeOnly
  end

  struct Token
    @mode : TokenMode
    @locale : Lang
    @text : String
    @keywords : String
    property index_limit : UInt8

    def self.normalize(word)
      return nil if word.blank?
      word = word.downcase

      return nil if Lexer::Eng::STOP_WORDS.includes?(word)

      # TODO: use https://snowballstem.org/
      word.stem
    end

    def initialize(@mode : TokenMode = TokenMode::NormalizeOnly, @text : String = "", @locale : Lang = Lang::Eng, @index_limit : UInt8 = Store::MAX_TERM_INDEX_SIZE, @keywords : String = "")
      # Tokenize words depending on the locale
      # @words = case @locale
      #          when Lang::Cmn
      #            TokenLexerWords::JieBa(TOKENIZER_JIEBA.cut(@text, false).to_a)
      #          when Lang::Jpn
      #            begin
      #              TokenLexerWords::Lindera(TOKENIZER_LINDERA.tokenize(@text).to_a)
      #            rescue err : Exception
      #              warn "unable to tokenize japanese, falling back: #{err}"
      #              TokenLexerWords::UAX29(@text.unicode_words.to_a)
      #            end
      #          else
      #            TokenLexerWords::UAX29(@text.unicode_words.to_a)
      #          end

    end

    def parse_text
      result = [] of String | UInt32

      parse_text do |term, hash, index|
        result << term
        result << hash
        result << index.to_u32
      end

      result
    end

    def parse_text
      words = @text.split(/[^A-Za-z0-9]+/)
      yields = Set(TermHash).new

      words.each_with_index do |word, index|

        next if !(norm_word = Token.normalize word)

        term_hash = Store::Hasher.to_compact norm_word

        if yields.add? term_hash
          Log.debug { "Lexer yielded #{term_hash}" }

          index = @index_limit if index > @index_limit

          yield norm_word, term_hash, index.to_u8
        else
          Log.debug { "Lexer did not yield #{term_hash} because already in set" }
        end
      end

      return if @keywords.blank?

      # handle low quality words always at last word position
      # keywords, channel name, description, etc
      words = @keywords.split(/[^A-Za-z0-9]+/)

      words.each do |word|

        next if !(norm_word = Token.normalize word)

        term_hash = Store::Hasher.to_compact norm_word

        if yields.add? term_hash
          Log.debug { "Lexer yielded #{term_hash}" }

          yield norm_word, term_hash, @index_limit
        else
          Log.debug { "Lexer did not yield #{term_hash} because already in set" }
        end
      end
    end
  end

end

