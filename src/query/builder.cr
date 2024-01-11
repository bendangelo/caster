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

  struct Result
    property type, item, token, query_id, limit, offset

    def initialize(@type : Type, @item : Store::Item, @token : Lexar::Token, @query_id : String = "", @limit : Int32 = 0, @offset : Int32 = 0)
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
    ) : Result?
      item = Store::ItemBuilder.from_depth_2(collection, bucket)

      lang, mode = Lexar::TokenBuilder.from_query_lang lang_code
      text_lexed = Lexar::TokenBuilder.from(mode, text, lang)

      return nil if item.is_a? Store::ItemError
      return nil if text_lexed.nil?

      Result.new Type::Search, item, text_lexed, query_id, limit, offset
    end
    #
    # def self.suggest(
    #   query_id : String,
    #   collection : String,
    #   bucket : String,
    #   terms : String,
    #   limit : QuerySearchLimit
    # ) : Result
    #   store = StoreItemBuilder.from_depth_2(collection, bucket).to_result
    #   text_lexed = Lexar::TokenBuilder.from(TokenMode::NormalizeOnly, terms).to_result
    #
    #   return Ok(Query::Suggest(store, query_id, text_lexed, limit)) if store && text_lexed
    #   Err(Nil)
    # end
    #
    # def self.list(
    #   query_id : String,
    #   collection : String,
    #   bucket : String,
    #   limit : QuerySearchLimit,
    #   offset : QuerySearchOffset
    # ) : Result
    #   store = StoreItemBuilder.from_depth_2(collection, bucket).to_result
    #   return Ok(Query::List(store, query_id, limit, offset)) if store
    #   Err(Nil)
    # end
    #
    def self.push(
      collection : String,
      bucket : String,
      object : String,
      text : String,
      lang_code : String?
    ) : Result?
      item = Store::ItemBuilder.from_depth_3(collection, bucket, object)
      lang, mode = Lexar::TokenBuilder.from_query_lang lang_code
      text_lexed = Lexar::TokenBuilder.from(mode, text, lang)

      return nil if item.is_a? Store::ItemError
      return nil if text_lexed.nil?

      return Result.new(Type::Push, item, text_lexed)
    end
    #
    # def self.pop(
    #   collection : String,
    #   bucket : String,
    #   object : String,
    #   text : String
    # ) : Result
    #   store = StoreItemBuilder.from_depth_3(collection, bucket, object).to_result
    #   text_lexed = Lexar::TokenBuilder.from(TokenMode::NormalizeOnly, text).to_result
    #
    #   return Ok(Query::Pop(store, text_lexed)) if store && text_lexed
    #   Err(Nil)
    # end
    #
    # def self.count(
    #   collection : String,
    #   bucket : String? = nil,
    #   object : String? = nil
    # ) : Result
    #   store_result = case [bucket, object]
    #                   when [Some(bucket_inner), Some(object_inner)]
    #                     StoreItemBuilder.from_depth_3(collection, bucket_inner, object_inner)
    #                   when [Some(bucket_inner), nil]
    #                     StoreItemBuilder.from_depth_2(collection, bucket_inner)
    #                   else
    #                     StoreItemBuilder.from_depth_1(collection)
    #                 end
    #
    #   return Ok(Query::Count(store_result)) if store_result
    #   Err(Nil)
    # end
    #
    # def self.flushc(collection : String) : Result
    #   store = StoreItemBuilder.from_depth_1(collection).to_result
    #   return Ok(Query::FlushC(store)) if store
    #   Err(Nil)
    # end
    #
    # def self.flushb(
    #   collection : String,
    #   bucket : String
    # ) : Result
    #   store = StoreItemBuilder.from_depth_2(collection, bucket).to_result
    #   return Ok(Query::FlushB(store)) if store
    #   Err(Nil)
    # end
    #
    # def self.flusho(
    #   collection : String,
    #   bucket : String,
    #   object : String
    # ) : Result
    #   store = StoreItemBuilder.from_depth_3(collection, bucket, object).to_result
    #   return Ok(Query::FlushO(store)) if store
    #   Err(Nil)
    # end
  end
end
