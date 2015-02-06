require 'everyday_natsort_kernel'

require 'rbe/data/data_store'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

root_command[:var] = command(aliases: %w(variable v), short_desc: 'var SUBCOMMAND ARGS...', desc: 'configure stored variables')

root_command[:var][:add] = command(short_desc: 'add VAR_NAME DEFAULT_VALUE', desc: 'add/modify a variable default value') { |name, value|
  Rbe::Data::DataStore.vars.save_local = options[:local]
  Rbe::Data::DataStore.vars[name]      = value
}

root_command[:var][:add][:local] = flag(aliases: %w(-l), type: :boolean, desc: 'add/modify local variables')

root_command[:var][:list_add] = command(short_desc: 'list-add VAR_NAME DEFAULT_VALUES...', desc: 'add/modify a variable default value list') { |name, *values|
  Rbe::Data::DataStore.vars.save_local = options[:local]
  Rbe::Data::DataStore.vars[name]      = values
}

root_command[:var][:list_add][:local] = flag(aliases: %w(-l), type: :boolean, desc: 'add/modify local variable value lists')

root_command[:var][:list_sort] = command(short_desc: 'list-sort VAR_NAME', desc: 'sort a variable default value list') { |name|
  Rbe::Data::DataStore.vars.save_local   = options[:local]
  Rbe::Data::DataStore.vars.search_local = options[:local]
  arr                                    = Rbe::Data::DataStore.vars[name]
  Rbe::Data::DataStore.vars[name]        = arr.natural_sort if arr.is_a?(Array)
}

root_command[:var][:list_sort][:local] = flag(aliases: %w(-l), type: :boolean, desc: 'sort local variable value lists')

root_command[:var][:var_sort] = command(short_desc: 'var-sort', desc: 'sort the variables in the vars.rbe.yaml file') {
  Rbe::Data::DataStore.vars.save_local   = options[:local]
  Rbe::Data::DataStore.vars.search_local = options[:local]
  Rbe::Data::DataStore.vars.sort_vars
}

root_command[:var][:var_sort][:local] = flag(aliases: %w(-l), type: :boolean, desc: 'sort the variables in the local vars.rbe.yaml file')

root_command[:var][:list] = command(aliases: %w(ls), short_desc: 'list [var_name]', desc: 'list the variables with defaults, optionally filtering by variable name') { |var_name = nil|
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

root_command[:var][:remove] = command(aliases: %w(rm delete), short_desc: 'remove var_name', desc: 'remove a variable default value') { |var_name|
  Rbe::Data::DataStore.vars.save_local = options[:local]
  Rbe::Data::DataStore.vars.delete(var_name) if Rbe::Data::DataStore.vars.has_key?(var_name)
}

root_command[:var][:remove][:local] = flag(aliases: %w(-l), type: :boolean, desc: 'remove local variables')

root_command[:var][:rewrite] = command(aliases: %w(rw), short_desc: 'rewrite', desc: 'rewrite the variable storage files to fix formatting differences caused by manual editing') {
  Rbe::Data::DataStore.vars.write_vars
  puts 'Vars rewritten'
}