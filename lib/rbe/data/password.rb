require 'keychain'

module Rbe::Data
  class Password
    class << self
      def user
        `whoami`.chomp
      end

      def get
        kc = Keychain.generic_passwords.where(service: 'rbe').first
        kc && kc.password
      end

      def set(password)
        kc = Keychain.generic_passwords.where(service: 'rbe').first
        if kc.nil?
          Keychain.generic_passwords.create(service: 'rbe', password: password, account: self.user)
        else
          kc.password = password
        end
        self.get.nil? ? :failure : :success
      end

      def delete
        kc = Keychain.generic_passwords.where(service: 'rbe').first
        if kc.nil?
          :nil
        else
          kc.delete
          kc = Keychain.generic_passwords.where(service: 'rbe').first
          kc.nil? ? :success : :failure
        end
      end
    end
  end
end