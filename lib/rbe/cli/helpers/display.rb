require 'everyday-plugins'
require 'rbe/data/data_store'

module Rbe::Cli::Helpers
  class Display
    extend Plugin

    register(:helper, name: 'print_cmd', global: true) { |sudo, cmd, *args|
      arr = array_to_args(args)
      puts "> #{sudo.nil? ? '' : "#{sudo} "}#{cmd} #{arr.join(' ')}"
    }

    register(:helper, name: 'print_list', global: true) { |cmd_id, indent = 0, lc = false|
      if lc
        cmds = []
        cmds << cmd_id if Rbe::Data::DataStore.command(cmd_id)
      else
        cmds = Rbe::Data::DataStore.commands.keys
        cmds = cmds.grep(/.*#{cmd_id}.*/) if cmd_id
        cmds.sort!
      end
      if cmds.nil? || cmds.empty?
        puts "#{' ' * indent}Did not find any commands matching #{cmd_id}"
      else
        longest_cmd = lc || cmds.map { |v| v.to_s.length }.max
        cmds.each { |cmd|
          info = Rbe::Data::DataStore.command(cmd)
          info.vars.keys.each { |k| Rbe::Data::DataStore.temp_vars[k.to_s] = info.vars[k] } if info.vars
          if info.command.is_a?(Array)
            puts "#{' ' * indent}#{cmd.to_s.ljust(longest_cmd + 2)}=> [\n"
            lc2 = info.command.map { |v| v.to_s.length }.max
            info.command.each { |cmd2| print_list("#{cmd2}#{info.sudo.nil? ? '' : (info.sudo == 'rvmsudo' ? '_rs' : '_s')}#{info.silent.nil? ? '' : (info.silent ? '_sl' : '_nsl')}", indent + longest_cmd + 7, lc2) }
            puts "#{' ' * indent}#{' ' * (longest_cmd + 4)} ]"
          else
            puts "#{' ' * indent}#{cmd.to_s.ljust(longest_cmd + 2)}=> #{info.silent ? '(silent) ' : ''}#{info.sudo.nil? ? '' : "#{info.sudo} "}#{info.command.gsub(/{{([\w\d]+)}}/) { |_| Rbe::Data::DataStore.var($1) }} #{array_to_args(info.args).join(' ')}"
          end
        }
      end
    }
  end
end