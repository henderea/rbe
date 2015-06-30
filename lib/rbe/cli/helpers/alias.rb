require 'rbe/data/data_store'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

global.helpers[:update_rbe_reload] =->(prefix) {
  IO.write(File.expand_path('~/rbe_reload.sh'),
<<EOS
function rbe_reload {
    #{prefix}
    rbe alias update
    source ~/rbe_reload.sh
    source ~/rbe_aliases.sh
}
EOS
  )
}

global.helpers[:update_rbe_aliases] =->(prefix) {
  list = Rbe::Data::DataStore.aliases.list
  str  = <<EOS
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
function rccs {
    #{prefix}
    rbe c cmd-sort
}
function rvvs {
    #{prefix}
    rbe var var-sort
}
function rvls {
    #{prefix}
    rbe var list-sort $@
}
function raa {
    #{prefix}
    rbe alias add $@
    rbe_reload
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
}

global.helpers[:update_bashrc] =-> {
  load_line = '[[ -s "$HOME/rbe_reload.sh" ]] && source "$HOME/rbe_reload.sh" && [[ -s "$HOME/rbe_aliases.sh" ]] && source "$HOME/rbe_aliases.sh" # Load rbe alias functions'
  lines     = IO.readlines(File.expand_path('~/.bashrc')).map(&:chomp)
  ind       = -1
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

global.helpers[:edit_static_alias] =->(alias_name) {
  comment_line = <<EOS
## You are editing the contents of the bash alias function "#{alias_name}".
## The "function #{alias_name} {" and closing "}" are automatically added in, so please leave them out here.
EOS
  original_content = Rbe::Data::DataStore.static_aliases[alias_name] || ''
  file_name = "/tmp/#{alias_name}.rbe-static-alias.sh"
  IO.write(file_name, "#{comment_line}\n#{original_content}")
  system("vi #{file_name}")
  new_content = IO.readlines(file_name)
}