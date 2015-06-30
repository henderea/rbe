require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

root_command[:about] = command(short_desc: 'about', desc: 'print out basic about info') { print_about_text }