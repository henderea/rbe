require 'everyday-plugins'
require 'rbe/data/data_store'

module Rbe::Cli::Helpers
  class Vars
    extend Plugin

    register(:helper, name: 'subs_vars', global: true) { |cmd_arr, arr, prompt_if_missing_required = false|
      ind_to_remove = []
      cmd_arr2      = cmd_arr.map { |v|
        v.gsub(/{{([#]?[\w\d]+)(?:[=][>](\d+))?}}/) { |_|
          ind_to_remove << $2.to_i if arr.count > 0 && $2 && arr[$2.to_i]
          Rbe::Data::DataStore.var($1, prompt_if_missing_required, arr.count > 0 && $2 && arr[$2.to_i])
        }
      }
      arr2          = [].replace(arr)
      ind_to_remove.uniq.sort.reverse_each { |itr| arr2.delete_at(itr) }
      [[*cmd_arr2, *arr2], cmd_arr2, arr2]
    }

    register(:helper, name: 'count_ind_vars', global: true) { |cmd, cmd_arr|
      [1, *([cmd, *cmd_arr].map { |v|
        [%w(0 0), *(v.scan(/{{([#]?[\w\d]+)(?:[=][>](\d+))?}}/))].map { |v2|
          v2[1].to_i + 1
        }.max
      })].max
    }
  end
end