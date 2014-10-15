require 'everyday-plugins'
require 'rbe/data/data_store'

module Rbe::Cli::Helpers
  class Running
    extend Plugin

    register(:helper, name: 'run_cmd', global: true) { |sudo_command, cmd, *args|
      arr = array_to_args(args, true)
      if sudo_command.nil?
        system("#{cmd} #{arr.join(' ')}")
      else
        run_sudo(sudo_command, cmd, *args)
      end
    }

    register(:helper, name: 'exec_cmd', global: true) { |cmd_id, *extra_args|
      cmd = Rbe::Data::DataStore.command(cmd_id)
      cmd.vars.keys.each { |k| Rbe::Data::DataStore.temp_vars[k.to_s] = cmd.vars[k] } if cmd.vars
      options[:cmd_var].keys.each { |k| Rbe::Data::DataStore.temp_vars[k.to_s] = options[:cmd_var][k] } if options[:cmd_var]
      if cmd
        if cmd.command.is_a?(Array)
          puts "> #{cmd.sudo.nil? ? '' : "#{cmd.sudo} "}rbe cmd group-exec #{cmd_id.to_s} #{array_to_args(extra_args).join(' ')}" unless cmd.silent
          cmd.command.each { |c| exec_cmd("#{c}#{cmd.sudo.nil? ? '' : (cmd.sudo == 'rvmsudo' ? '_rs' : '_s')}#{cmd.silent.nil? ? '' : (cmd.silent ? '_sl' : '_nsl')}", *extract_args(c, *extra_args)) }
        else
          cmd_with_vars = cmd.command.gsub(/{{([\w\d]+)}}/) { |_| Rbe::Data::DataStore.var($1) }
          print_cmd(cmd.sudo, cmd_with_vars, *cmd.args, *extra_args) unless cmd.silent
          run_cmd(cmd.sudo, cmd_with_vars, *cmd.args, *extra_args)
        end
      else
        puts "Could not find command #{cmd_id.to_s}"
      end
    }
  end
end