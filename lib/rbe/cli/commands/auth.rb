require 'rbe/data/data_store'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

root_command[:auth] = command(short_desc: 'auth', desc: 'authenticate and save password in keychain') {
  pw     = getpass
  result = Rbe::Data::DataStore.password.set(pw)
  Rbe::IO.puts result == :success ? 'Success!' : 'Failure'
}

root_command[:test_auth] = command(short_desc: 'test-auth', desc: 'test stored password') {
  pw = Rbe::Data::DataStore.password.get
  if pw.nil?
    Rbe::IO.puts 'You need to call `rbe auth` first!'
  else
    Rbe::IO.puts testpass(pw) ? 'Success!' : 'Failure'
  end
}

root_command[:unauth] = command(short_desc: 'unauth', desc: 'remove stored password from keychain') {
  result = Rbe::Data::DataStore.password.delete
  if result == :nil
    Rbe::IO.puts 'No stored password!'
  elsif result == :success
    Rbe::IO.puts 'Password forgotten'
  else
    Rbe::IO.puts 'Failure to forget password'
  end
}