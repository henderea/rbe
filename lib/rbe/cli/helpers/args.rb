require 'shellwords'
require 'rbe/data/data_store'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

global.helpers[:array_to_args] =->(cmd_arr, arr, prompt_if_missing_required = false) {
  subs_vars(cmd_arr, arr, prompt_if_missing_required).first.map { |v|
    (v =~ /^(\||\d?>|<|\$\(|;|[&]{1,2}$)/).nil? ? Shellwords.escape(v).gsub(/\\*\+/, '+').gsub(/\\*[{]\\*[{]\\*([#])?/, '{{\1').gsub(/\\*[}]\\*[}]/, '}}').gsub(/\\*[*]/, '*') : v
  }
}

global.helpers[:extract_args] =->(cmd_id, *args) {
  arr = []
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