require 'rbe/io'
require 'rbe/data/data_store'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

global.helpers[:testpass] =->(pw = nil) {
  test = pw.nil? ? `sudo echo "Success" 2>&1`.chomp : `echo "#{pw}" | sudo -S echo "Success" 2>&1`.chomp
  test.include?('Success')
}

global.helpers[:getpass] =->() {
  user = Rbe::Data::DataStore.user
  begin
    Rbe::IO.print "Password for user #{user}: "
    pw = Rbe::IO.noecho(&:gets)
    puts
  end until testpass(pw)
  pw
}

global.helpers[:run_sudo] =->(sudo_command, cmd, cmd_args, args) {
  arr = array_to_args(cmd_args, args)
  pw  = Rbe::Data::DataStore.password.get
  if pw.nil?
    pw = getpass
  else
    unless testpass(pw)
      Rbe::IO.puts 'Stored password invalid!'
      pw = getpass
    end
  end
  sudo_command = 'sudo' unless sudo_command == 'rvmsudo' && `which rvmsudo`.chomp.include?('rvmsudo')
  system(testpass ? "#{sudo_command} #{cmd} #{arr.join(' ')}" : "echo '#{pw}' | #{sudo_command} -S #{cmd} #{arr.join(' ')}")
}