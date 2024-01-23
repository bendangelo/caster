module Executer

  module Filter
    def self.execute(method : String, item_value : UInt32, value_first : UInt32, value_second : UInt32) : Bool

      case method
      when "time"
        return Time.utc.to_unix - item_value <= value_first
      when "equal"
        return item_value == value_first
      when "between"
        if value_second == 0
          return item_value >= value_first
        end

        return item_value >= value_first && item_value <= value_second
      else
        true
      end
    end
  end
end
