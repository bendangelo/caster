module Pipe

  enum CommandError
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
    Ok
    Pong
    Pending #(String)
    Result #(String)
    Event #(String, String, String)
    Ended #(String)
    Err #(CommandError)
  end

  EVENT_ID_SIZE = 8

  TEXT_PART_BOUNDARY = '"'
  TEXT_PART_ESCAPE = '\\'
  META_PART_GROUP_OPEN = '('
  META_PART_GROUP_CLOSE = ')'

  BACKUP_KV_PATH = "kv"
  BACKUP_FST_PATH = "fst"

  class Command
  end
end
