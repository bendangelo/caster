module Pipe
  class IngestCommand

    def self.dispatch_push(input : String) : CommandResult
      parts, text = BaseCommand.parse_args_with_text(input)
      collection, bucket, object = parts.shift?, parts.shift?, parts.shift?

      if collection && bucket && object && text
        Log.info { "dispatching ingest push in collection: #{collection}, bucket: #{bucket} and object: #{object} with text (#{text})" }

        # Define push parameters

        # Parse meta parts (meta comes after text; extract meta parts second)
        push_lang = BaseCommand.parse_meta parts, "LANG"

        if text.blank?
          CommandResult.error CommandError::InvalidFormat, "text is blank"
        else
          Log.info { "will push for text: #{text} with hinted locale: #{push_lang}" }

          # Commit 'push' query
          return BaseCommand.commit_ok_operation Query::Builder.push(collection, bucket, object, text, push_lang)
        end
      else
        CommandResult.error CommandError::InvalidFormat, "PUSH <collection> <bucket> <object> [LANG value]? -- <text>"
      end
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

      if collection && !bucket && !object && !extra
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
    #
    # def self.handle_push_meta(meta_result : MetaPartsResult) : Result(Option(QueryGenericLang), PipeCommandError)
    #   case meta_result
    #   when Ok([meta_key, meta_value])
    #     Log.info { "handle push meta: #{meta_key} = #{meta_value}" }
    #
    #     case meta_key
    #     when "LANG"
    #       # 'LANG(<locale>)' where <locale> ∈ ISO 639-3
    #       query_lang_parsed = QueryGenericLang.from_value(meta_value)
    #
    #       if query_lang_parsed
    #         Ok(Some(query_lang_parsed))
    #       else
    #         Err(BaseCommand.make_error_invalid_meta_value(meta_key, meta_value))
    #       end
    #     else
    #       Err(BaseCommand.make_error_invalid_meta_key(meta_key, meta_value))
    #     end
    #   when Err(err)
    #     Err(BaseCommand.make_error_invalid_meta_key(err[0], err[1]))
    #   end
    # end
  end
end
