module Caster
  class Settings
    include YAML::Serializable
    include YAML::Serializable::Unmapped

    property log_level : Int32
    property colorize : Bool

    property inet : String
    property port : Int32
    property tcp_timeout : Int32 = 300

    property auth_password : String = ""
  end
end
