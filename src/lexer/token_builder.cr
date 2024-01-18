module Lexer


  enum TokenLexerWords
    UAX29
    # Add other words variants based on features
  end

  # Constants
  TEXT_LANG_TRUNCATE_OVER_CHARS = 200
  TEXT_LANG_DETECT_PROCEED_OVER_CHARS = 20
  TEXT_LANG_DETECT_NGRAM_UNDER_CHARS = 60

  # # Lazy initialization for Chinese tokenizer (replace with actual initialization)
  # # Comment out the next line if the "tokenizer-chinese" feature is not present
  # # TOKENIZER_JIEBA : JiebaRS::Jieba = JiebaRS::Jieba.new
  #
  # # Lazy initialization for Japanese tokenizer (replace with actual initialization)
  # # Comment out the next line if the "tokenizer-japanese" feature is not present
  # # TOKENIZER_LINDERA : TokenizerJapanese::Tokenizer = TokenizerJapanese::Tokenizer.new
  #
  # # Mocking the lazy_static! macro for Crystal (use regular lazy initialization instead)
  # macro lazy_static(type, name, &block)
  #   # Your lazy initialization logic here
  # end
  #
  # # Mocking the lazy_static! macro usage for Chinese tokenizer
  # # Comment out the next line if the "tokenizer-chinese" feature is not present
  # lazy_static(JiebaRS::Jieba, TOKENIZER_JIEBA) do
  #   JiebaRS::Jieba.new
  # end
  #
  # # Mocking the lazy_static! macro usage for Japanese tokenizer
  # # Comment out the next line if the "tokenizer-japanese" feature is not present
  # lazy_static(TokenizerJapanese::Tokenizer, TOKENIZER_LINDERA) do
  #   TokenizerJapanese::Tokenizer.new
  # end

  module TokenBuilder


    TEXT_LANG_TRUNCATE_OVER_CHARS = 200
    TEXT_LANG_DETECT_PROCEED_OVER_CHARS = 20
    TEXT_LANG_DETECT_NGRAM_UNDER_CHARS = 60

    def self.from_query_lang(lang)
      # TODO: find lang
      {TokenMode::NormalizeOnly, Lang::Eng}
    end

    def self.from(mode, text, hinted_lang = nil, index_limit = Store::MAX_TERM_INDEX_SIZE, keywords = nil, headers = nil)

      locale = case mode
               when TokenMode::HintedCleanup
                 # Detect text language (current lexer mode asks for cleanup)
                 Log.info { "detecting locale from lexer text: #{text}" }
                 # detect_lang(text)
                 Lang::Eng

               when TokenMode::NormalizeAndCleanup
                 if hinted_lang.nil?
                   Lang::Eng
                 else
                   # Use hinted language (current lexer mode asks for cleanup)
                   Log.info { "using hinted locale: #{hinted_lang} from lexer text: #{text}" }
                   # lang
                   hinted_lang
                 end

               when TokenMode::NormalizeOnly
                 Log.info { "not detecting locale from lexer text: #{text}" }
                 # May be 'NormalizeOnly' mode; no need to perform locale detection
                 Lang::Eng
               else
                 Lang::None
               end

      # Build final token builder iterator
      Token.new(mode, text, locale, index_limit, keywords || "", headers || "")
    end

    # private def detect_lang(text : String) : Lang?
    #   # Detect only if text is long enough to allow the text locale detection system to function properly
    #   return nil if text.size < TEXT_LANG_DETECT_PROCEED_OVER_CHARS
    #
    #   # Truncate text if necessary, as to avoid the ngram or stopwords detector to be
    #   # ran on more words than those that are enough to reliably detect a locale.
    #   safe_text = if text.size > TEXT_LANG_TRUNCATE_OVER_CHARS
    #                 puts "lexer text needs to be truncated, as it is too long (#{text.size}/#{TEXT_LANG_TRUNCATE_OVER_CHARS}): #{text}"
    #                 # Perform an UTF-8 aware truncation
    #                 # Notice: the 'size' check above was not UTF-8 aware, but is better than
    #                 # nothing as it avoids entering the below iterator for small strings.
    #                 # Notice: we fallback on text if the result is 'nil'; if it is 'nil' there
    #                 # were fewer characters than the truncate limit in the UTF-8 parsed text. With
    #                 # this unwrap-way, we avoid doing a 'text.chars.size' every time, which is
    #                 # a O(N) operation, and rather guard this block with a 'text.size' which is
    #                 # a O(1) operation but which is not 100% reliable when approaching the truncate
    #                 # limit. This is a trade-off, which saves quite a lot CPU cycles at scale.
    #                 text[0, text.char_index(TEXT_LANG_TRUNCATE_OVER_CHARS)&.first]
    #               else
    #                 text
    #               end
    #
    #   puts "will detect locale for lexer safe text: #{safe_text}"
    #
    #   # Attempt to detect the locale from text using a hybrid method that maximizes both
    #   # accuracy and performance.
    #   # Notice: as the 'ngram' method is almost 10x slower than the 'stopwords' method, we
    #   # prefer using the 'stopwords' method on long texts where we can be sure to see quite
    #   # a lot of stopwords which will produce a reliable result. However, for shorter texts
    #   # there are not enough north none stopwords, thus we use the slower 'ngram' method as
    #   # an attempt to extract the locale using trigrams. Still, if either of these methods
    #   # fails at detecting a locale it will try using the other method in fallback as to
    #   # produce the most reliable result while minimizing CPU cycles.
    #   if safe_text.size < TEXT_LANG_DETECT_NGRAM_UNDER_CHARS
    #     puts "lexer text is shorter than #{TEXT_LANG_DETECT_NGRAM_UNDER_CHARS} characters, using the slow method"
    #     detect_lang_slow(safe_text)
    #   else
    #     puts "lexer text is equal or longer than #{TEXT_LANG_DETECT_NGRAM_UNDER_CHARS} characters, using the fast method"
    #     detect_lang_fast(safe_text)
    #   end
    # end
    #
    # private def detect_lang_slow(safe_text : String) : Lang?
    #   ngram_start = Time.monotonic
    #
    #   detector = lang_detect_all(safe_text)
    #
    #   if detector
    #     ngram_took = Time.monotonic - ngram_start
    #     locale = detector.lang
    #
    #     puts "[slow lexer] locale detected from text: #{safe_text} (#{locale} from #{detector.script} at #{detector.confidence}/1; #{ngram_took}s)"
    #     # Confidence is low, try to detect locale from stop-words.
    #     # Notice: this is a fallback but should not be too reliable for short
    #     # texts.
    #     unless detector.is_reliable
    #       puts "[slow lexer] trying to detect locale from stopwords instead"
    #       alternate_locale = LexerStopWord.guess_lang(safe_text, detector.script)
    #       if alternate_locale
    #         puts "[slow lexer] detected more accurate locale from stopwords: #{alternate_locale}"
    #         locale = alternate_locale
    #       end
    #     end
    #
    #     locale
    #   else
    #     puts "[slow lexer] no locale could be detected from text: #{safe_text}"
    #     nil
    #   end
    # end
    #
    # private def detect_lang_fast(safe_text : String) : Lang?
    #   stopwords_start = Time.monotonic
    #
    #   script = script_detect(safe_text)
    #
    #   if script
    #     # Locale found?
    #     if locale = LexerStopWord.guess_lang(safe_text, script)
    #       stopwords_took = Time.monotonic - stopwords_start
    #       puts "[fast lexer] locale detected from text: #{safe_text} (#{locale}; #{stopwords_took}s)"
    #       locale
    #     else
    #       puts "[fast lexer] trying to detect locale from fallback ngram instead"
    #       # No locale found, fallback on slow ngram.
    #       lang_detect(safe_text)
    #     end
    #   else
    #     puts "[fast lexer] no script could be detected from text: #{safe_text}"
    #     nil
    #   end
    # end

    # impl<'a> TokenLexerIterator for Token<'a>
    #   def next : Tuple(String, TermHash)?
    #     while word = @words.next
    #       # Lower-case word
    #       word = word.downcase
    #
    #       # Check if normalized word is a stop-word? (if should normalize and cleanup)
    #       if @mode == TokenMode::NormalizeOnly || !LexerStopWord.is(word, @locale)
    #         # Hash the term (this is used by all iterator consumers, as well as internally \
    #         #   in the iterator to keep track of already-yielded words in a space-optimized \
    #         #   manner, ie. by using 32-bit unsigned integer hashes)
    #         term_hash = StoreTermHash.new(word)
    #
    #         # Check if word was not already yielded? (we return unique words)
    #         if !@yields.contains?(term_hash)
    #           puts "lexer yielded word: #{word}"
    #           @yields << term_hash
    #           return {word, term_hash}
    #         else
    #           puts "lexer did not yield word: #{word} because: word already yielded"
    #         end
    #       else
    #         puts "lexer did not yield word: #{word} because: word is a stop-word"
    #       end
    # end
    #
    # nil
    # end
  end

  # module Whatlang
  #   # Mocking the detect function for illustrative purposes
  #   def self.detect(text : String, lang : Lang) : Option(Lang)
  #     # Your detection logic here
  #     # This is just a placeholder
  #     Some(Lang::Eng)
  #   end
  #
  #   # Mocking the detect_lang function for illustrative purposes
  #   def self.detect_lang(text : String) : Option(Lang)
  #     # Your detection logic here
  #     # This is just a placeholder
  #     Some(Lang::Eng)
  #   end
  #
  #   # Mocking the detect_script function for illustrative purposes
  #   def self.detect_script(text : String) : Option(Script)
  #     # Your detection logic here
  #     # This is just a placeholder
  #     Some(Script::Latin)
  #   end
  #
  #   # Enum for Lang and Script, replace with actual enums
  #   enum Lang
  #     Eng
  #     # Add other languages
  #   end
  #
  #   enum Script
  #     Latin
  #     # Add other scripts
  #   end
  # end
  #
  # module JiebaRS
  #   # Mocking the Jieba struct for illustrative purposes
  #   struct Jieba
  #     # Your Jieba struct implementation here
  #   end
  # end
  #
  # module TokenizerJapanese
  #   # Mocking the Tokenizer struct for illustrative purposes
  #   struct Tokenizer
  #     # Your Tokenizer struct implementation here
  #   end
  # end
  #
  # module LinderaTokenizer
  #   # Mocking the Token struct for illustrative purposes
  #   struct Token
  #     # Your Token struct implementation here
  #   end
  #
  #   # Mocking the TokenizerConfig struct for illustrative purposes
  #   struct TokenizerConfig
  #     # Your TokenizerConfig struct implementation here
  #   end
  #
  #   # Mocking the DictionaryConfig struct for illustrative purposes
  #   struct DictionaryConfig
  #     # Your DictionaryConfig struct implementation here
  #   end
  #
  #   # Mocking the DictionaryKind enum for illustrative purposes
  #   enum DictionaryKind
  #     UniDic
  #     # Add other dictionary kinds
  #   end
  # end
  end
