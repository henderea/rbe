require 'everyday_natsort_kernel'

module Rbe::Data
  class AbstractGlobalList
    class << self
      def abstract(*names)
        names.each { |name|
          define_method(name.to_sym) { |*args| raise "Method #{__method__}(#{args.join(', ')}) not implemented." }
        }
      end
    end

    abstract :file_name
    abstract :list
    abstract :list=
    abstract :has_key?
    abstract :keys
    abstract :each
    abstract :[]
    abstract :[]=
    abstract :delete

    def on_init
      #do nothing
    end

    def initialize
      load_list
      on_init
    end

    def sort_list
      self.list = Hash[self.list.natural_sort]
      save_list
    end

    def load_list
      self.list = File.exist?(File.expand_path("~/#{self.file_name}")) ? YAML::load_file(File.expand_path("~/#{self.file_name}")) : {}
    end

    def save_list
      IO.write(File.expand_path("~/#{self.file_name}"), self.list.to_yaml) unless @no_save
    end

    def no_save
      @no_save = true
      yield
      @no_save = false
    end

    protected :save_list, :save_local_list, :load_list, :load_local_list, :list, :local_list, :list=, :local_list=, :on_init
  end
end