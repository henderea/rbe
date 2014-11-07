require 'shellwords'
require 'everyday-plugins'
require 'rbe/data/data_store'

module Rbe::Cli::Helpers
  class Args
    extend Plugin

    register(:helper, name: 'array_to_args', global: true) { |cmd_arr, arr, prompt_if_missing_required = false|
      subs_vars(cmd_arr, arr, prompt_if_missing_required).first.map { |v|
        (v =~ /^(\||\d?>|<|\$\(|;|[&]{1,2}$)/).nil? ? Shellwords.escape(v).gsub(/\\*\+/, '+').gsub(/\\*[{]\\*[{]\\*([#])?/, '{{\1').gsub(/\\*[}]\\*[}]/, '}}').gsub(/\\*[*]/, '*') : v
      }
    }

    register(:helper, name: 'extract_args', global: true) { |cmd_id, *args|
      arr   = []
      found = true
      args.each { |v|
        if v.start_with?('+')
          cur_id = v[1..-1]
          found  = cur_id == cmd_id || cur_id.start_with?("#{cmd_id}+")
          arr << cur_id[(cmd_id.length)..-1] if cur_id.start_with?("#{cmd_id}+")
        elsif found
          arr << v
        end
      }
      arr
    }
  end
end