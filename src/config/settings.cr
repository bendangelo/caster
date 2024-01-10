module Caster
  class Settings
    include YAML::Serializable

    property log_level : Int32
    property colorize : Bool

    property inet : String
    property port : Int32
    property tcp_timeout : Int32 = 300

    property auth_password : String = ""

    property search : SearchSettings
    property kv : KVSettings
  end

  class KVSettings
    include YAML::Serializable

    property path : String
    property pool : PoolSettings
    property database : DatabaseSettings
  end

  class PoolSettings
    include YAML::Serializable

    property inactive_after : Int32
  end

  class DatabaseSettings
    include YAML::Serializable

    property flush_after : Int32
    property compress : Bool # not implemented
    property parallelism : Int32
    property max_files : Int32 = -1
    property max_compactions : Int32
    property max_flushes : Int32
    property write_buffer : Int32
    property write_ahead_log : Bool
  end

  class SearchSettings
    include YAML::Serializable

    property query_limit_default : Int32
    property query_limit_maximum : Int32
  end
end
