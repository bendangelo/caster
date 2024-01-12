module Pipe
  class ControlCommand
    def self.dispatch_trigger(parts) : CommandResult
      return CommandResult.error CommandError::InvalidFormat
      # case [parts.shift?, parts.shift?, parts.shift?]
      # when [nil, _, _]
      #   Ok([ChannelCommandResponse::Result.new("actions(#{CONTROL_TRIGGER_ACTIONS.join(", ")})")])
      # when [Some(action_key), data_part, last_part]
      #   action_key_lower = action_key.downcase
      #
      #   case action_key_lower
      #   when "consolidate"
      #     if data_part.nil?
      #       # Force a FST consolidate
      #       StoreFSTPool.consolidate(true)
      #       Ok([ChannelCommandResponse::Ok.new])
      #     else
      #       Err(PipeCommandError::InvalidFormat.new("TRIGGER consolidate"))
      #     end
      #   when "backup"
      #     case [data_part, last_part]
      #     when [Some(path), nil]
      #       # Proceed KV + FST backup
      #       path = Path.new(path)
      #
      #       if Store::KVPool.backup(path.join(BACKUP_KV_PATH)).is_ok &&
      #          StoreFSTPool.backup(path.join(BACKUP_FST_PATH)).is_ok
      #         Ok([ChannelCommandResponse::Ok.new])
      #       else
      #         Err(PipeCommandError::InternalError.new)
      #       end
      #     else
      #       Err(PipeCommandError::InvalidFormat.new("TRIGGER backup <path>"))
      #     end
      #   when "restore"
      #     case [data_part, last_part]
      #     when [Some(path), nil]
      #       # Proceed KV + FST restore
      #       path = Path.new(path)
      #
      #       if Store::KVPool.restore(path.join(BACKUP_KV_PATH)).is_ok &&
      #          StoreFSTPool.restore(path.join(BACKUP_FST_PATH)).is_ok
      #         Ok([ChannelCommandResponse::Ok.new])
      #       else
      #         Err(PipeCommandError::InternalError.new)
      #       end
      #     else
      #       Err(PipeCommandError::InvalidFormat.new("TRIGGER restore <path>"))
      #     end
      #   else
      #     Err(PipeCommandError::NotFound.new)
      #   end
      # else
      #   Err(PipeCommandError::InvalidFormat.new("Invalid command format"))
      # end
    end

    def self.dispatch_info(parts) : CommandResult
      case parts.shift?
      when nil
        # statistics = ChannelStatistics.gather

        stats = "uptime({}) clients_connected({}) commands_total({})
           command_latency_best({}) command_latency_worst({})
           kv_open_count({}) fst_open_count({}) fst_consolidate_count({})"

        CommandResult.new ResponseType::Ok, stats
        # Ok([ChannelCommandResponse::Result.new(format(
        #   statistics.uptime,
        #   statistics.clients_connected,
        #   statistics.commands_total,
        #   statistics.command_latency_best,
        #   statistics.command_latency_worst,
        #   statistics.kv_open_count,
        #   statistics.fst_open_count,
        #   statistics.fst_consolidate_count
        # ))])
      else
        return CommandResult.error CommandError::InvalidFormat, "INFO"
      end
    end

    # def self.dispatch_help(parts) : CommandResult
    #   ChannelCommandBase.generic_dispatch_help(parts, &*MANUAL_MODE_CONTROL)
    # end
  end
end
