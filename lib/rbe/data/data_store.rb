require_relative 'command_list'
require_relative 'var_list'
require_relative 'alias_list'
require_relative 'password'

module Rbe::Data
  class DataStore
    class << self
      def commands
        @commands ||= Rbe::Data::CommandList.new
      end

      def vars
        @vars ||= Rbe::Data::VarList.new
      end

      def aliases
        @aliases ||= Rbe::Data::AliasList.new
      end

      def temp_vars
        vars.temp_vars
      end

      def command(cmd_id)
        self.commands.command(cmd_id)
      end

      def var(var_name, prompt_if_missing_required = false, default = nil)
        vars.get(var_name, prompt_if_missing_required, default)
      end

      def user
        Rbe::Data::Password.user
      end

      def password
        Rbe::Data::Password
      end
    end
  end
end