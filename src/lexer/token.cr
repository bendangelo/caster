module Lexar
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
    @words : Array(String)
    @yields : Set(TermHash)

    def initialize(@mode : TokenMode, @text : String, @locale : Lang)
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
      @words = @text.split " "

      @yields = Set(TermHash).new
    end

    def each
      @words.each do |word|
        word = word.downcase

        # TODO: if stop word, skip...

        term_hash = Store::Hasher.to_compact word

        if @yields.add? term_hash
          Log.debug { "Lexar yielded #{term_hash}" }

          yield word, term_hash
        else
          Log.debug { "Lexar did not yield #{term_hash} because already in set" }
        end
      end
    end
  end

end

