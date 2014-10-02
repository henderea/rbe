require 'everyday-plugins'

module Rbe::Cli::Commands
  class Sudo
    extend Plugin

    register(:command, id: :sudo, parent: nil, aliases: %w(s), name: 'sudo', short_desc: 'sudo COMMAND ARGS...', desc: 'run a sudo with the stored password filled in for you') { |*args|
      cmd = args.delete_at(0)
      run_sudo(options[:rvm_sudo] ? 'rvmsudo' : 'sudo', cmd, *args)
    }

    register :flag, name: :rvm_sudo, parent: :sudo, aliases: %w(-r), type: :boolean, desc: 'use rvmsudo instead of sudo'
  end
end