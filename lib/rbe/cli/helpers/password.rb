require 'io/console'
require 'everyday-plugins'
require 'rbe/data/data_store'

module Rbe::Cli::Helpers
  class Password
    extend Plugin

    register(:helper, name: 'testpass', global: true) { |pw = nil|
      test = pw.nil? ? `sudo echo "Success" 2>&1`.chomp : `echo "#{pw}" | sudo -S echo "Success" 2>&1`.chomp
      test.include?('Success')
    }

    register(:helper, name: 'getpass', global: true) {
      user = Rbe::Data::DataStore.user
      begin
        print "Password for user #{user}: "
        pw = STDIN.noecho(&:gets)
        puts
      end until testpass(pw)
      pw
    }

    register(:helper, name: 'run_sudo', global: true) { |sudo_command, cmd, cmd_args, args|
      arr = array_to_args(cmd_args, args)
      pw  = Rbe::Data::DataStore.password.get
      if pw.nil?
        pw = getpass
      else
        unless testpass(pw)
          puts 'Stored password invalid!'
          pw = getpass
        end
      end
      sudo_command = 'sudo' unless sudo_command == 'rvmsudo' && `which rvmsudo`.chomp.include?('rvmsudo')
      system(testpass ? "#{sudo_command} #{cmd} #{arr.join(' ')}" : "echo '#{pw}' | #{sudo_command} -S #{cmd} #{arr.join(' ')}")
    }
  end
end