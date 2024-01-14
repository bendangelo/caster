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

    # all enums output to uppercase for responses
    def to_s
      {% begin %}
        case self
          {% for member in @type.constants %}
            in .{{ member.id.downcase }}?
              "{{ member.id.upcase }}"
          {% end %}
        end
      {% end %}
    end
  end

  struct CommandResult
    property type, value, error

    def initialize(@type : ResponseType, @value : String = "", @error : CommandError = CommandError::None)
    end

    def self.ok : CommandResult
      CommandResult.new ResponseType::Ok
    end

    def self.error(error : CommandError, value = "") : CommandResult
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

    def self.parse_attrs(parts, key, if_none = nil)
      index = parts.index(key)

      return if_none if index.nil?

      value = parts[index + 1]? || if_none

      return value if value.nil?

      value.split(",").map {|i| i.to_u16 }
    end

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

      # return CommandResult.new(:pending, query_id),
      CommandResult.new(type: :event, value: event_value)
    end

  end
end
