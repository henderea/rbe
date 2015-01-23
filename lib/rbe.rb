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

if time_load
  rtd01 = (rt1-t1)*1000
  rtd12 = (rt2-rt1)*1000
  rtd23 = (rt3-rt2)*1000
  rtd34 = (rt4-rt3)*1000
  rtd45 = (t2-rt4)*1000
  td12 = (t2-t1)*1000
  td23 = (t3-t2)*1000
  td34 = (t4-t3)*1000
  td24 = (t4-t2)*1000
  td14 = (t4-t1)*1000
  strs = []
  strs << "total time:                 #{('%.3f' % td14).rjust(10)} ms"
  strs << "require time:               #{('%.3f' % td12).rjust(10)} ms (#{'%.3f' % ((td12 / td14) * 100.0)}%)"
  strs << " -- thor:                   #{('%.3f' % rtd01).rjust(10)} ms (#{'%.3f' % ((rtd01 / td12) * 100.0)}%)"
  strs << " -- etu/builder:            #{('%.3f' % rtd12).rjust(10)} ms (#{'%.3f' % ((rtd12 / td12) * 100.0)}%)"
  strs << " -- rbe/cli/helpers:        #{('%.3f' % rtd23).rjust(10)} ms (#{'%.3f' % ((rtd23 / td12) * 100.0)}%)"
  strs << " -- rbe/cli/commands:       #{('%.3f' % rtd34).rjust(10)} ms (#{'%.3f' % ((rtd34 / td12) * 100.0)}%)"
  strs << " -- include ETU::Builder:   #{('%.3f' % rtd45).rjust(10)} ms (#{'%.3f' % ((rtd45 / td12) * 100.0)}%)"
  strs << "build time:                 #{('%.3f' % td23).rjust(10)} ms (#{'%.3f' % ((td23 / td14) * 100.0)}%)"
  strs << "add_debugging time:         #{('%.3f' % td34).rjust(10)} ms (#{'%.3f' % ((td34 / td14) * 100.0)}%)"
  strs << "build + add_debugging time: #{('%.3f' % td24).rjust(10)} ms (#{'%.3f' % ((td24 / td14) * 100.0)}%)"
  ml = strs.map { |s| s.length }.max
  strs = strs.map { |s| "| #{s.ljust(ml)} |" }
  strs.unshift("+#{'-' * (ml + 2)}+")
  strs << "+#{'-' * (ml + 2)}+"
  strs.each { |s| puts s }
  puts
  puts
end