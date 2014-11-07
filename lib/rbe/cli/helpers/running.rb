require 'everyday-plugins'
require 'rbe/data/data_store'

module Rbe::Cli::Helpers
  class Running
    extend Plugin

    register(:helper, name: 'run_cmd', global: true) { |sudo_command, cmd, cmd_args, args|
      arr = array_to_args(cmd_args, args, true)
      if sudo_command.nil?
        system("#{cmd} #{arr.join(' ')}")
      else
        run_sudo(sudo_command, cmd, cmd_args, args)
      end
    }

    register(:helper, name: 'exec_cmd', global: true) { |cmd_id, *extra_args|
      options[:var].keys.each { |k| Rbe::Data::DataStore.temp_vars[k.to_s] = options[:var][k] } if options[:var]
      cmd_id = subs_vars([cmd_id], extra_args, true).first.first
      cmd    = Rbe::Data::DataStore.command(cmd_id)
      if cmd
        cmd.vars.keys.each { |k| Rbe::Data::DataStore.temp_vars[k.to_s] = cmd.vars[k] } if cmd.vars
        if cmd.command.is_a?(Array)
          puts "> #{cmd.sudo.nil? ? '' : "#{cmd.sudo} "}rbe cmd group-exec #{clean_cmd(cmd_id.to_s)} #{array_to_args([], extra_args).join(' ')}" unless cmd.silent
          cmd.command.each { |c| exec_cmd("#{c}#{cmd.sudo.nil? ? '' : (cmd.sudo == 'rvmsudo' ? '_rs' : '_s')}#{cmd.silent.nil? ? '' : (cmd.silent ? '_sl' : '_nsl')}", *extract_args(c, *extra_args)) }
        else
          part = count_ind_vars(cmd.command, cmd.args)
          if cmd.should_loop && part < extra_args.count
            if extra_args.empty?
              puts "Command #{clean_cmd(cmd_id.to_s)} requires extra args"
              exit 1
            else
              args = extra_args
              cnt  = (args.count.to_f / part.to_f).ceil
              begin
                cur_args = args.slice!(0, part)
                exec_cmd(cmd_id, *cur_args)
                cnt2 = cnt - (args.count.to_f / part.to_f).ceil
                puts "\n===== #{cnt2} of #{cnt} done (#{'%.2f' % ((cnt2.to_f / cnt.to_f) * 100)}%) =====\n\n"
              end until args.nil? || args.empty?
            end
          else
            cmd_with_vars = subs_vars([cmd.command], extra_args, true).first.first
            print_cmd(cmd.sudo, cmd_with_vars, cmd.args, extra_args) unless cmd.silent
            run_cmd(cmd.sudo, cmd_with_vars, cmd.args, extra_args)
          end
        end
      else
        puts "Could not find command #{cmd_id.to_s}"
      end
    }
  end
end