require 'rbe/data/data_store'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

root_command[:cmd] = command(aliases: %w(command c), short_desc: 'cmd SUBCOMMAND ARGS...', desc: 'configure/run stored commands')

root_command[:cmd][:add] = command(aliases: %w(reg register), short_desc: 'add cmd_id cmd args...', desc: 'register a command by name') { |cmd_id, cmd, *args|
  Rbe::Data::DataStore.commands.save_local = options[:local]
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

root_command[:cmd][:add][:local] = flag(aliases: %w(-l), type: :boolean, desc: 'add/modify local commands')

root_command[:cmd][:group_add] = command(aliases: %w(group_reg group_register), short_desc: 'group-add cmd_id cmd...', desc: 'register a command group by name') { |cmd_id, *cmds|
  Rbe::Data::DataStore.commands.save_local = options[:local]
  Rbe::Data::DataStore.commands[cmd_id]    = { command: Array(cmds), sudo: nil, args: nil, vars: options[:var] }
}

root_command[:cmd][:group_add][:var] = flag(aliases: %w(-v), type: :hash, desc: 'set a variable value for the commands in the group')
root_command[:cmd][:group_add][:local] = flag(aliases: %w(-l), type: :boolean, desc: 'add/modify local command groups')

root_command[:cmd][:cmd_sort] = command(short_desc: 'cmd-sort', desc: 'sort the commands in the commands.rbe.yaml file') {
  Rbe::Data::DataStore.commands.save_local   = options[:local]
  Rbe::Data::DataStore.commands.sort_commands
}

root_command[:cmd][:cmd_sort][:local] = flag(aliases: %w(-l), type: :boolean, desc: 'sort the commands in the local commands.rbe.yaml file')

root_command[:cmd][:list] = command(aliases: %w(ls), short_desc: 'list [cmd_id]', desc: 'list registered commands that match argument or all commands if no argument provided') { |cmd_id = nil|
  print_list(cmd_id)
}

root_command[:cmd][:exec] = command(aliases: %w(do e group-exec ge), short_desc: 'exec cmd_id [extra_args...]', desc: 'execute registered command (or command group) that matches argument (append _s to force sudo) (extra_args used normally for single commands, use +cmd_id to specify for a certain cmd, +cmd_grp_id+cmd_id for a subgroup command, and so on)') { |cmd_id, *extra_args|
  exec_cmd(cmd_id, *extra_args)
}

root_command[:cmd][:exec][:var] = flag(aliases: %w(-v), type: :hash, desc: 'set a temporary variable value')

root_command[:cmd][:remove] = command(aliases: %w(rm unreg unregister delete), name: 'remove', short_desc: 'remove cmd_id', desc: 'remove a registered command or command group') { |cmd_id|
  Rbe::Data::DataStore.commands.save_local = options[:local]
  Rbe::Data::DataStore.commands.delete(cmd_id) if Rbe::Data::DataStore.commands.has_key?(cmd_id)
}

root_command[:cmd][:remove][:local] = flag(aliases: %w(-l), type: :boolean, desc: 'remove local commands or command groups')