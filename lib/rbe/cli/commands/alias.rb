require 'rbe/data/data_store'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

root_command[:alias] = command(short_desc: 'alias SUBCOMMAND ARGS...', desc: 'configure command bash aliases')

root_command[:alias][:add] = command(short_desc: 'add cmd_id', desc: 'register an alias') { |cmd_id|
  if Rbe::Data::DataStore.command(cmd_id).nil?
    puts "Command with id #{cmd_id} does not seem to exist."
  else
    Rbe::Data::DataStore.aliases << cmd_id.to_s
  end
}

root_command[:alias][:remove] = command(aliases: %w(rm delete), short_desc: 'remove cmd_id', desc: 'remove an alias for a command') { |cmd_id|
  Rbe::Data::DataStore.aliases.delete(cmd_id)
}

root_command[:alias][:list] = command(aliases: %w(ls), short_desc: 'list', desc: 'list the commands with aliases') {
  puts Rbe::Data::DataStore.aliases.list.join("\n")
}

root_command[:alias][:update] = command(aliases: %w(up), short_desc: 'update [prefix="rvm reload 2>&- >&-"]', desc: 'update the bash files for the aliases that are registered with an optional prefix command') { |prefix = 'rvm reload 2>&- >&-'|
  IO.write(File.expand_path('~/rbe_reload.sh'),
<<EOS
function rbe_reload {
    source ~/rbe_reload.sh
    source ~/rbe_aliases.sh
}
EOS
)
  list = Rbe::Data::DataStore.aliases.list
  str = <<EOS
function rvsu {
    #{prefix}
    rbe s --rvm-sudo $@
}
function rsu {
    #{prefix}
    rbe s $@
}
function rce {
    #{prefix}
    rbe c e $@
}
function rta {
    #{prefix}
    rbe test-auth $@
}
EOS
  list.each { |li|
    str << <<EOS
function #{li.to_s} {
    rce #{li.to_s} $@
}
EOS
  }
  IO.write(File.expand_path('~/rbe_aliases.sh'), str)

  load_line = '[[ -s "$HOME/rbe_reload.sh" ]] && source "$HOME/rbe_reload.sh" && rbe_reload # Load rbe_reload.sh'
  lines = IO.readlines(File.expand_path('~/.bashrc')).map(&:chomp)
  ind = -1
  lines.each_with_index { |l, i|
    if l.to_s.include? 'rbe_reload.sh'
      ind = i
      break
    end
  }
  if ind >= 0
    lines[ind] = load_line
  else
    lines << load_line
  end

  IO.write(File.expand_path('~/.bashrc'), lines.join("\n"))
}