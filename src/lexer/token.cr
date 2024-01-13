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

    def initialize(@mode : TokenMode = TokenMode::NormalizeOnly, @text : String = "", @locale : Lang = Lang::Eng)
      # TODO: add rocks flushing and batch write
      # TODO: index words based on position (index to a max in the settings)
      # TODO: fetch based on all words being in list
      # TODO: save metadata for iid
      # TODO: add ORDER to query and ASC / DESC ex: QUERY videos all ORDER 0 ASC -- my query
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
      words = @text.split(/\W+/)
      yields = Set(TermHash).new

      words.each_with_index do |word, index|
        word = word.downcase

        next if word.blank? || Lexer::Eng::STOP_WORDS.includes?(word)

        # TODO: use https://snowballstem.org/
        word = word.stem

        term_hash = Store::Hasher.to_compact word

        if yields.add? term_hash
          Log.debug { "Lexer yielded #{term_hash}" }
          yield word, term_hash, index
        else
          Log.debug { "Lexer did not yield #{term_hash} because already in set" }
        end
      end

    end
  end

end

