require 'everyday-plugins'
require 'rbe/data/data_store'

module Rbe::Cli::Commands
  class Auth
    extend Plugin

    register(:command, id: :auth, parent: nil, name: 'auth', short_desc: 'auth', desc: 'authenticate and save password in keychain') {
      pw     = getpass
      result = Rbe::Data::DataStore.password.set(pw)
      puts result == :success ? 'Success!' : 'Failure'
    }

    register(:command, id: :test_auth, parent: nil, name: 'test_auth', short_desc: 'test-auth', desc: 'test stored password') {
      pw = Rbe::Data::DataStore.password.get
      if pw.nil?
        puts 'You need to call `rbe auth` first!'
      else
        puts testpass(pw) ? 'Success!' : 'Failure'
      end
    }

    register(:command, id: :unauth, parent: nil, name: 'unauth', short_desc: 'unauth', desc: 'remove stored password from keychain') {
      result = Rbe::Data::DataStore.password.delete
      if result == :nil
        puts 'No stored password!'
      elsif result == :success
        puts 'Password forgotten'
      else
        puts 'Failure to forget password'
      end
    }
  end
end