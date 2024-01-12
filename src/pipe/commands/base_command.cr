module Pipe

  enum CommandError
    None
    UnknownCommand
    NotFound
    QueryError
    InternalError
    ShuttingDown
    PolicyReject
    InvalidFormat
    InvalidMetaKey
    InvalidMetaValue
  end

  enum ResponseType
    Void
    Ok
    Pong
    Pending #(String)
    Result #(String)
    Event #(String, String, String)
    Ended #(String)
    Err #(CommandError)
  end

  struct CommandResult
    property type, value, error

    def initialize(@type : ResponseType, @value : String = "", @error : CommandError = CommandError::None)
    end

    def self.ok : CommandResult
      CommandResult.new ResponseType::Ok
    end

    def self.error(error, value = "") : CommandResult
      CommandResult.new ResponseType::Err, value, error
    end

    def self.query_error : CommandResult
      CommandResult.new ResponseType::Err, CommandError::QueryError
    end

    def self.make_error_invalid_meta_key(meta_key : String, meta_value : String)
      CommandResult.new(ResponseType::Err, "#{meta_key} #{meta_value}", CommandError::InvalidMetaKey)
    end

    def self.make_error_invalid_meta_value(meta_key : String, meta_value : String)
      CommandResult.new(ResponseType::Err, "#{meta_key} #{meta_value}", CommandError::InvalidMetaValue)
    end

  end

  class BaseCommand
    EVENT_ID_SIZE = 8

    @@random = Random.new(0)

    def self.generate_event_id : String
      @@random.base64 EVENT_ID_SIZE
    end

    TEXT_PART_BOUNDARY = '"'
    TEXT_PART_ESCAPE = '\\'
    META_PART_GROUP_OPEN = '('
    META_PART_GROUP_CLOSE = ')'

    BACKUP_KV_PATH = "kv"
    BACKUP_FST_PATH = "fst"

    def self.parse_args_with_text(input : String)
      args, divider, text = input.partition " -- "

      return args.split(" "), Utils.unescape(text)
    end

    def self.parse_args(input : String)
      return input.split(" ")
    end

    def self.parse_meta(parts, key, if_none = nil)
      index = parts.index(key)

      return if_none if index.nil?

      parts[index + 1]? || if_none
    end

    # def self.parse_text_parts(parts : Array(String)) : String?
    #   text = String.new
    #
    #   parts.each do |text_part|
    #     text += " " unless text.empty?
    #
    #     text += text_part
    #
    #     if text.size > 1 && text[-1] == TEXT_PART_BOUNDARY
    #       count_escapes = 0
    #
    #       if text.size > 1
    #         (text.size - 2).downto(0) do |index|
    #           break if text[index] != TEXT_PART_ESCAPE
    #
    #           count_escapes += 1
    #         end
    #       end
    #
    #       if count_escapes == 0 || (count_escapes % 2 == 0)
    #         break
    #       end
    #     end
    #   end
    #
    #   if text.empty? || text.size < 2 || text[0] != TEXT_PART_BOUNDARY ||
    #       text[-1] != TEXT_PART_BOUNDARY
    #     Log.error { "could not properly parse text parts: #{text}" }
    #     nil
    #   else
    #     Log.info { "parsed text parts (still needs post-processing): (#{text})" }
    #
    #     text_inner = text[1..text.size - 2]
    #
    #     text_inner_string = Utils.unescape(text_inner)
    #
    #     Log.info { "parsed text parts (post-processed): (#{text_inner_string})" }
    #
    #     text_inner_string.blank? ? nil : text_inner_string
    #   end
    # end
    #
    # def self.parse_next_meta_parts(parts : Array(String)) : Tuple(ResponseType, String, String)
    #   part = parts.shift?
    #
    #   if part
    #     if !part.empty?
    #       index_open = part.index(META_PART_GROUP_OPEN)
    #
    #       if index_open
    #         key_bound_start = 0
    #         key_bound_end = index_open
    #         value_bound_start = index_open + 1
    #         value_bound_end = part.size - 1
    #
    #         if part[value_bound_end].ord.to_char == META_PART_GROUP_CLOSE
    #           key = part[key_bound_start..key_bound_end]
    #           value = part[value_bound_start..value_bound_end]
    #
    #           unless key.include?(META_PART_GROUP_OPEN) || key.include?(META_PART_GROUP_CLOSE) ||
    #               value.include?(META_PART_GROUP_OPEN) || value.include?(META_PART_GROUP_CLOSE)
    #             Log.debug { "parsed meta part as: #{key} = #{value}" }
    #             return {ResponseType::Ok, key, value}
    #           else
    #             Log.debug { "parsed meta part, but it contains reserved characters: #{key} = #{value}" }
    #             return {ResponseType::Err, key, value}
    #           end
    #         end
    #       end
    #     end
    #
    #     Log.error { "could not parse meta part: #{part}" }
    #     {ResponseType::Err, "?", part}
    #   else
    #     nil
    #   end
    # end

    def self.commit_ok_operation(query) : CommandResult
      return CommandResult.error CommandError::QueryError if query.nil?

      Store::Operation.dispatch query

      CommandResult.ok
    end

    def self.commit_result_operation(query) : CommandResult
      return CommandResult.error CommandError::QueryError if query.nil?

      results = Store::Operation.dispatch query

      return CommandResult.error CommandError::InternalError if results.nil?

      CommandResult.new type: ResponseType::Result, value: results
    end

    def self.commit_pending_operation(query_type : String, query_id : String, query)
      return CommandResult.error CommandError::QueryError if query.nil?

      results = Store::Operation.dispatch query

      return CommandResult.error CommandError::QueryError if results.nil?

      if results.blank?
        event_value = "#{query_type} #{query_id}"
      else
        event_value = "#{query_type} #{query_id} #{results}"
      end

      return CommandResult.new(:pending, query_id),
        CommandResult.new(type: ResponseType::Event, value: event_value)
    end

  end
end
