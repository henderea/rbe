require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

root_command[:sudo] = command(aliases: %w(s), short_desc: 'sudo COMMAND ARGS...', desc: 'run a sudo with the stored password filled in for you') { |cmd, *args|
  run_sudo(options[:rvm_sudo] ? 'rvmsudo' : 'sudo', cmd, [], args)
}

root_command[:sudo][:rvm_sudo] = flag(aliases: %w(-r), type: :boolean, desc: 'use rvmsudo instead of sudo')