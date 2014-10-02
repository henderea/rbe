require 'everyday-plugins'
require 'rbe/data/data_store'

module Rbe::Cli::Commands
  class Command
    extend Plugin

    register :command, id: :cmd, parent: nil, aliases: %w(command c), name: 'cmd', short_desc: 'cmd SUBCOMMAND ARGS...', desc: 'configure/run stored commands'

    register(:command, id: :cmd_add, parent: :cmd, aliases: %w(reg register), name: 'add', short_desc: 'add cmd_id cmd args...', desc: 'register a command by name') { |cmd_id, cmd, *args|
      if cmd == 'sudo'
        sudo = 'sudo'
        cmd  = args.shift
      elsif cmd == 'rvmsudo'
        sudo = 'rvmsudo'
        cmd  = args.shift
      else
        sudo = nil
      end
      Rbe::Data::DataStore.commands[cmd_id] = { command: cmd, sudo: sudo, args: args, vars: nil }
    }

    register(:command, id: :cmd_group_add, parent: :cmd, aliases: %w(group_reg group_register), name: 'group_add', short_desc: 'group-add cmd_id cmd...', desc: 'register a command group by name') { |cmd_id, *cmds|
      Rbe::Data::DataStore.commands[cmd_id] = { command: Array(cmds), sudo: nil, args: nil, vars: options[:cmd_var] }
    }

    register :flag, name: :cmd_var, parent: :cmd_group_add, aliases: %w(-v), type: :hash, desc: 'set a variable value for the commands in the group'

    register(:command, id: :cmd_list, parent: :cmd, aliases: %w(ls), name: 'list', short_desc: 'list [cmd_id]', desc: 'list registered commands that match argument or all commands if no argument provided') { |cmd_id = nil|
      print_list(cmd_id)
    }

    register(:command, id: :cmd_exec, parent: :cmd, aliases: %w(do e group-exec ge), name: 'exec', short_desc: 'exec cmd_id [extra_args...]', desc: 'execute registered command (or command group) that matches argument (append _s to force sudo) (extra_args used normally for single commands, use +cmd_id to specify for a certain cmd, +cmd_grp_id+cmd_id for a subgroup command, and so on)') { |cmd_id, *extra_args|
      exec_cmd(cmd_id, *extra_args)
    }

    register :flag, name: :cmd_var, parent: :cmd_exec, aliases: %w(-v), type: :hash, desc: 'set a temporary variable value'

    register(:command, id: :cmd_remove, parent: :cmd, aliases: %w(rm unreg unregister delete), name: 'remove', short_desc: 'remove cmd_id', desc: 'remove a registered command or command group') { |cmd_id|
      Rbe::Data::DataStore.commands.delete(cmd_id) if Rbe::Data::DataStore.commands.has_key?(cmd_id)
    }
  end
end