require 'everyday-plugins'
require 'rbe/data/data_store'

module Rbe::Cli::Commands
  class Var
    extend Plugin

    register :command, id: :var, parent: nil, aliases: %w(variable v), name: 'var', short_desc: 'var SUBCOMMAND ARGS...', desc: 'configure stored variables'

    register(:command, id: :var_add, parent: :var, name: 'add', short_desc: 'add VAR_NAME DEFAULT_VALUE', desc: 'add/modify a variable default value') { |name, value|
      Rbe::Data::DataStore.vars.save_local = options[:local]
      Rbe::Data::DataStore.vars[name] = value
    }

    register :flag, name: :local, parent: :var_add, aliases: %w(-l), type: :boolean, desc: 'add/modify local variables'

    register(:command, id: :var_list, parent: :var, aliases: %w(ls), name: 'list', short_desc: 'list [var_name]', desc: 'list the variables with defaults, optionally filtering by variable name') { |var_name = nil|
      vars = Rbe::Data::DataStore.vars.keys
      vars = vars.grep(/.*#{var_name}.*/) if var_name
      vars.sort!
      if vars.nil? || vars.empty?
        puts "Did not find any variables matching #{var_name}"
      else
        longest_var = vars.map { |v| v.to_s.length }.max
        vars.each { |v| puts "#{v.to_s.ljust(longest_var)} => #{Rbe::Data::DataStore.vars[v].to_s}" }
      end
    }

    register(:command, id: :var_remove, parent: :var, aliases: %w(rm delete), name: 'remove', short_desc: 'remove var_name', desc: 'remove a variable default value') { |var_name|
      Rbe::Data::DataStore.vars.save_local = options[:local]
      Rbe::Data::DataStore.vars.delete(var_name) if Rbe::Data::DataStore.vars.has_key?(var_name)
    }

    register :flag, name: :local, parent: :var_remove, aliases: %w(-l), type: :boolean, desc: 'remove local variables'
  end
end