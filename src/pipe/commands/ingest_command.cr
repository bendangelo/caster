module Pipe

  struct PushParams
    include JSON::Serializable
    property collection : String, bucket : String, object : String, lang : String?, attrs : Array(UInt32)?, text : String, keywords : String?
  end

  class IngestCommand

    def self.dispatch_push(input : String) : CommandResult
      params = PushParams.from_json input
      # parts, text = BaseCommand.parse_args_with_text(input)
      collection, bucket, object = params.collection, params.bucket, params.object
      text = params.text

      if collection && bucket && object && text
        Log.info { "dispatching ingest push in collection: #{collection}, bucket: #{bucket} and object: #{object} with text (#{text})" }

        if text.blank?
          CommandResult.error CommandError::InvalidFormat, "text is blank"
        else
          Log.info { "will push for text: #{text} with hinted locale: #{params.lang}" }

          # Commit 'push' query
          item = Store::ItemBuilder.from_depth_3(collection, bucket, object)
          mode, hinted_lang = Lexer::TokenBuilder.from_query_lang params.lang
          token = Lexer::TokenBuilder.from(mode, text, hinted_lang, params.keywords)

          return CommandResult.error :query_error if item.is_a? Store::ItemError
          return CommandResult.error :query_error if token.nil?

          Executer::Push.execute item, token, params.attrs

          return CommandResult.ok
        end
      else
        CommandResult.error CommandError::InvalidFormat, "PUSH <json>"
      end
    rescue e : JSON::ParseException
      CommandResult.error CommandError::InvalidFormat, e.message || ""
    end

    def self.dispatch_pop(input) : CommandResult
      parts, text = BaseCommand.parse_args_with_text(input)
      collection, bucket, object = parts.shift?, parts.shift?, parts.shift?

      #
      # if collection && bucket && object && text && !_
      #   Log.info { "dispatching ingest pop in collection: #{collection}, bucket: #{bucket} and object: #{object}" }
      #   Log.info { "ingest pop has text: #{text}" }
      #
      #   # Make 'pop' query
      #   BaseCommand.commit_result_operation(
      #     Query::Builder.pop(collection, bucket, object, text)
      #   )
      # else
      return CommandResult.error CommandError::InvalidFormat, "POP <collection> <bucket> <object> -- <text>"
      # end
    end

    def self.dispatch_count(input) : CommandResult
      parts = BaseCommand.parse_args(input)
      collection, bucket, object, extra = parts.shift?, parts.shift?, parts.shift?, parts.shift?

      if collection && !extra
        Log.info { "dispatching ingest count in collection: #{collection}" }

        # Make 'count' query
        BaseCommand.commit_result_operation(
          Query::Builder.count(collection, bucket, object)
        )
      else
        return CommandResult.error CommandError::InvalidFormat, "COUNT <collection> [<bucket> [<object>]?]?"
      end
    end

    def self.dispatch_flushc(input) : CommandResult
      parts = BaseCommand.parse_args(input)
      collection, extra = parts.shift?, parts.shift?

      if collection && !extra
        Log.info { "dispatching ingest flush collection in collection: #{collection}" }

        # Make 'flushc' query
        BaseCommand.commit_result_operation(
          Query::Builder.flushc(collection)
        )
      else
        return CommandResult.error CommandError::InvalidFormat, "FLUSHC <collection>"
      end
    end

    def self.dispatch_flushb(input) : CommandResult
      parts = BaseCommand.parse_args(input)
      collection, bucket, extra = parts.shift?, parts.shift?, parts.shift?

      if collection && bucket && !extra
        Log.info { "dispatching ingest flush bucket in collection: #{collection}, bucket: #{bucket}" }

        # Make 'flushb' query
        BaseCommand.commit_result_operation(
          Query::Builder.flushb(collection, bucket)
        )
      else
        return CommandResult.error CommandError::InvalidFormat, "FLUSHB <collection> <bucket>"
      end
    end

    def self.dispatch_flusho(input) : CommandResult
      parts = BaseCommand.parse_args(input)
      collection, bucket, object, extra = parts.shift?, parts.shift?, parts.shift?, parts.shift?

      if collection && bucket && object && !extra
        Log.info { "dispatching ingest flush object in collection: #{collection}, bucket: #{bucket}, object: #{object}" }

        # Make 'flusho' query
        BaseCommand.commit_result_operation(
          Query::Builder.flusho(collection, bucket, object)
        )
      else
        return CommandResult.error CommandError::InvalidFormat, "FLUSHO <collection> <bucket> <object>"
      end
    end

    # def self.dispatch_help(parts) : CommandResult
    #   BaseCommand.generic_dispatch_help(parts, &*MANUAL_MODE_INGEST)
    # end
  end
end
