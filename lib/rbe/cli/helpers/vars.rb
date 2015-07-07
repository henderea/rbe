require 'rbe/data/data_store'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

global.helpers[:register_temp_vars] =->(vars) {
  vars.keys.each { |k| Rbe::Data::DataStore.temp_vars[k.to_s] = vars[k] } if vars
}

global.helpers[:subs_vars] =->(cmd_arr, arr, prompt_if_missing_required = false) {
  ind_to_remove = []
  cmd_arr2      = cmd_arr.map { |v|
    v.gsub(%r{[{][{]([#]?[\w\d]+)(?:[=][>](\d+))?(?:~/(.+)/[?][{](.*)[}][:][{](.*)[}])?[}][}]}) { |_|
      ind_to_remove << $2.to_i if arr.count > 0 && $2 && arr[$2.to_i]
      v = Rbe::Data::DataStore.var($1, prompt_if_missing_required, arr.count > 0 && $2 && arr[$2.to_i])
      if $3
        t = $4
        f = $5
        if v =~ /#{$3}/
          t
        else
          f
        end
      else
        v
      end
    }
  }
  arr2          = [].replace(arr)
  ind_to_remove.uniq.sort.reverse_each { |itr| arr2.delete_at(itr) }
  [[*cmd_arr2, *arr2], cmd_arr2, arr2]
}

global.helpers[:get_vars] =->(cmd_arr, arr) {
  ind_to_remove = []
  cmd_arr.each { |v|
    v.scan(%r{[{][{]([#]?[\w\d]+)(?:[=][>](\d+))?(?:~/(.+)/[?][{](.*)[}][:][{](.*)[}])?[}][}]}) { |vname, ind|
      unless vname == '_' || vname == '#_'
        ind_to_remove << ind.to_i if arr.count > 0 && ind && arr[ind.to_i]
        v = Rbe::Data::DataStore.var(vname, true, arr.count > 0 && ind && arr[ind.to_i])
        if $3
          t = $4
          f = $5
          if v =~ /#{$3}/
            t
          else
            f
          end
        else
          v
        end
      end
    }
  }
  arr2 = [].replace(arr)
  ind_to_remove.uniq.sort.reverse_each { |itr| arr2.delete_at(itr) }
  arr2
}

global.helpers[:count_ind_vars] =->(cmd, cmd_arr) {
  inds = [cmd, *cmd_arr].map { |v|
    v.scan(%r{[{][{][#]?_(?:[=][>](\d+))(?:~/(.+)/[?][{](.*)[}][:][{](.*)[}])?[}][}]}).map { |v2|
      v2[0].to_i
    }
  }.flatten.uniq
  inds = [0] if inds.empty?
  min  = inds.min
  max  = inds.max
  [min, max + 1 - min]
}