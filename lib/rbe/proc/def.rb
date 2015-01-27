require 'rbe/io'

class Proc
  class << self
    def abstract(*names)
      names.each { |name|
        define_method(name.to_sym) { |*args| raise "Method #{__method__}(#{args.join(', ')}) not implemented." }
      }
    end
  end

  abstract :proc_body

  attr_accessor :helper
end