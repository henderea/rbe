require 'rbe/data/data_store'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

root_command[:alias] = command(short_desc: 'alias SUBCOMMAND ARGS...', desc: 'configure command bash alias functions')

root_command[:alias][:add] = command(short_desc: 'add cmd_id...', desc: 'register an alias') { |*cmd_ids|
  cmd_ids.each { |cmd_id|
    if Rbe::Data::DataStore.command(cmd_id).nil?
      puts "Command with id #{cmd_id} does not seem to exist."
    else
      Rbe::Data::DataStore.aliases << cmd_id.to_s
    end
  }
}

root_command[:alias][:remove] = command(aliases: %w(rm delete), short_desc: 'remove cmd_id', desc: 'remove an alias for a command') { |cmd_id|
  Rbe::Data::DataStore.aliases.delete(cmd_id)
}

root_command[:alias][:list] = command(aliases: %w(ls), short_desc: 'list', desc: 'list the commands with aliases') {
  puts Rbe::Data::DataStore.aliases.list.join("\n")
}

root_command[:alias][:update] = command(aliases: %w(up), short_desc: 'update [prefix="rvm reload 2>&- >&-"]', desc: 'update the bash files for the aliases that are registered with an optional prefix command') { |prefix = 'rvm reload 2>&- >&-'|
  update_rbe_reload(prefix)
  update_rbe_aliases(prefix)
  update_bashrc
}