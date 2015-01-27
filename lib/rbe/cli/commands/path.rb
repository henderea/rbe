require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

root_command[:path] = command(short_desc: 'path', desc: 'print out the path of the current file') { Rbe::IO.puts __FILE__ }