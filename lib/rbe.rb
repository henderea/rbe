require 'rbe/version'

tl = ENV['time_load']
time_load = tl == '1' || tl == 1 || tl == 'true' || tl == 't'

t1 = Time.now if time_load

module Rbe
end

require 'thor'
rt1 = Time.now if time_load
require 'everyday_thor_util/builder'
rt2 = Time.now if time_load
require 'rbe/cli/helpers'
rt3 = Time.now if time_load
require 'rbe/cli/commands'
rt4 = Time.now if time_load
include EverydayThorUtil::Builder

t2 = Time.now if time_load

@rc = build!

t3 = Time.now if time_load

add_debugging(@rc, nil, 'debug')

t4 = Time.now if time_load

def ct(a, b)
  (a-b)*1000
end

def format_time(d, pd = nil)
  "#{('%.3f' % d).rjust(10)} ms#{pd.nil? ? '' : " (#{'%.3f' % ((d / pd) * 100.0)}%)"}"
end

if time_load
  rtd01 = ct(rt1, t1)
  rtd12 = ct(rt2, rt1)
  rtd23 = ct(rt3, rt2)
  rtd34 = ct(rt4, rt3)
  rtd45 = ct(t2, rt4)
  td12 = ct(t2, t1)
  td23 = ct(t3, t2)
  td34 = ct(t4, t3)
  td24 = ct(t4, t2)
  td14 = ct(t4, t1)
  strs = []
  strs << "total time:                 #{format_time(td14)}"
  strs << "require time:               #{format_time(td12, td14)}"
  strs << " -- thor:                   #{format_time(rtd01, td12)}"
  strs << " -- etu/builder:            #{format_time(rtd12, td12)}"
  strs << " -- rbe/cli/helpers:        #{format_time(rtd23, td12)}"
  strs << " -- rbe/cli/commands:       #{format_time(rtd34, td12)}"
  strs << " -- include ETU::Builder:   #{format_time(rtd45, td12)}"
  strs << "build time:                 #{format_time(td23, td14)}"
  strs << "add_debugging time:         #{format_time(td34, td14)}"
  strs << "build + add_debugging time: #{format_time(td24, td14)}"
  ml = strs.map { |s| s.length }.max
  strs = strs.map { |s| "| #{s.ljust(ml)} |" }
  strs.unshift("+#{'-' * (ml + 2)}+")
  strs << "+#{'-' * (ml + 2)}+"
  strs.each { |s| puts s }
  puts
  puts
end