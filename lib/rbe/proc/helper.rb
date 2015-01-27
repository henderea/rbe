require 'rbe/data/data_store'
require 'rbe/cli/helpers'

module Rbe
  module Proc
    class Helper
      class << self
        def get_var(var_name, prompt_if_missing_required = false, default = nil)
          Rbe::Data::DataStore.var(var_name, prompt_if_missing_required, default)
        end

        def set_temp_var(var_name, value)
          Rbe::Data::DataStore.temp_vars[var_name] = value
        end

        def exec_cmd(cmd_name, *extra_args)
          global.helpers[:exec_cmd].call(cmd_name, *extra_args)
        end
      end
    end
  end
end