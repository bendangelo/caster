module Query

  enum Type
    Search
    Suggest
    List
    Push
    Pop
    Count
    FlushC
    FlushB
    FlushO
  end

  struct ResultLexer
    property type, item, token, query_id, limit, offset

    def initialize(@type : Type, @item : Store::Item, @token : Lexer::Token, @query_id : String = "", @limit : Int32 = 0, @offset : Int32 = 0)
    end

  end

  struct Result
    property type, item, query_id, limit, offset

    def initialize(@type : Type, @item : Store::Item, @query_id : String = "", @limit : Int32 = 0, @offset : Int32 = 0)
    end

  end

  class Builder
    def self.search(
      query_id : String,
      collection : String,
      bucket : String,
      text : String,
      limit : Int32,
      offset : Int32,
      lang_code : String? = nil
    ) : ResultLexer?
      item = Store::ItemBuilder.from_depth_2(collection, bucket)

      mode, hinted_lang = Lexer::TokenBuilder.from_query_lang lang_code
      text_lexed = Lexer::TokenBuilder.from(mode, text, hinted_lang)

      return nil if item.is_a? Store::ItemError
      return nil if text_lexed.nil?

      ResultLexer.new Type::Search, item, text_lexed, query_id, limit, offset
    end

    def self.suggest(
      query_id : String,
      collection : String,
      bucket : String,
      terms : String,
      limit : Int32
    ) : ResultLexer?
      item = Store::ItemBuilder.from_depth_2(collection, bucket)
      text_lexed = Lexer::TokenBuilder.from(Lexer::TokenMode::NormalizeOnly, terms)

      return nil if item.is_a? Store::ItemError
      return nil if text_lexed.nil?

      return ResultLexer.new(Type::Suggest, item, text_lexed, query_id, limit)
    end

    def self.list(
      query_id : String,
      collection : String,
      bucket : String,
      limit : Int32,
      offset : Int32
    ) : Result?
      item = Store::ItemBuilder.from_depth_2(collection, bucket)

      return nil if item.is_a? Store::ItemError

      Result.new(Type::List, item: item, query_id: query_id, limit: limit, offset: offset)
    end

    def self.push(
      collection : String,
      bucket : String,
      object : String,
      text : String,
      lang_code : String?
    ) : ResultLexer?
      item = Store::ItemBuilder.from_depth_3(collection, bucket, object)
      mode, hinted_lang = Lexer::TokenBuilder.from_query_lang lang_code
      text_lexed = Lexer::TokenBuilder.from(mode, text, hinted_lang)

      return nil if item.is_a? Store::ItemError
      return nil if text_lexed.nil?

      return ResultLexer.new(Type::Push, item, text_lexed)
    end

    def self.pop(
      collection : String,
      bucket : String,
      object : String,
      text : String
    ) : ResultLexer?
      item = Store::ItemBuilder.from_depth_3(collection, bucket, object)
      text_lexed = Lexer::TokenBuilder.from(Lexer::TokenMode::NormalizeOnly, text)

      return nil if item.is_a? Store::ItemError
      return nil if text_lexed.nil?

      return ResultLexer.new(Type::Pop, item, text_lexed)
    end

    def self.count(
      collection : String,
      bucket : String? = nil,
      object : String? = nil
    ) : Result?
    item = if bucket && object
             Store::ItemBuilder.from_depth_3(collection, bucket, object)
           elsif bucket
             Store::ItemBuilder.from_depth_2(collection, bucket)
           else
             Store::ItemBuilder.from_depth_1(collection)
           end

      return nil if item.is_a? Store::ItemError

      Result.new(Type::Count, item)
    end

    def self.flushc(collection : String) : Result?
      item = Store::ItemBuilder.from_depth_1(collection)

      return nil if item.is_a? Store::ItemError

      Result.new(Type::FlushC, item)
    end

    def self.flushb(
      collection : String,
      bucket : String
    ) : Result?
      item = Store::ItemBuilder.from_depth_2(collection, bucket)

      return nil if item.is_a? Store::ItemError

      Result.new(Type::FlushB, item)
    end

    def self.flusho(
      collection : String,
      bucket : String,
      object : String
    ) : Result?
      item = Store::ItemBuilder.from_depth_3(collection, bucket, object)

      return nil if item.is_a? Store::ItemError

      Result.new(Type::FlushO, item)
    end
  end
end
