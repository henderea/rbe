module Rbe::Data
  class AbstractList
    attr_accessor :save_local

    class << self
      def abstract(*names)
        names.each { |name|
          define_method(name.to_sym) { |*args| raise "Method #{__method__}(#{args.join(', ')}) not implemented." }
        }
      end
    end

    abstract :file_name
    abstract :list, :local_list
    abstract :list=, :local_list=
    abstract :has_key?
    abstract :keys
    abstract :[]
    abstract :[]=
    abstract :delete

    def on_init
      #do nothing
    end

    def initialize
      @save_local = false
      load_list
      load_local_list
      on_init
    end

    def sort_list
      if @save_local
        self.local_list = Hash[self.local_list.natural_sort]
        save_local_list
      else
        self.list = Hash[self.list.natural_sort]
        save_list
      end
    end

    def load_local_list
      self.local_list = File.exist?(self.file_name) ? YAML::load_file(self.file_name) : {}
    end

    def save_local_list
      IO.write(self.file_name, self.local_list.to_yaml) unless @no_save
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