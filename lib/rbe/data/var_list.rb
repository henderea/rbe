require 'everyday_natsort_kernel'
require 'yaml'
require 'readline'

module Rbe::Data
  class VarList
    attr_accessor :save_local, :search_local

    def initialize
      @save_local   = false
      @search_local = true
      load_vars
      load_local_vars
    end

    def write_vars
      save_vars unless @vars.empty?
      save_local_vars unless @local_vars.empty?
    end

    def push_temp
      @temp_stack ||= []
      @temp_stack.unshift(self.temp_vars.select { |_, _| true })
    end

    def pop_temp
      @temp_stack ||= []
      tmp         = @temp_stack.shift
      @temp_vars  = tmp if tmp
    end

    def temp_vars
      @temp_vars ||= {}
    end

    def sort_vars
      if @save_local
        @local_vars = Hash[@local_vars.natural_sort]
        save_local_vars
      else
        @vars = Hash[@vars.natural_sort]
        save_vars
      end
    end

    def load_local_vars
      @local_vars = File.exist?('vars.rbe.yaml') ? YAML::load_file('vars.rbe.yaml') : {}
    end

    def save_local_vars
      IO.write('vars.rbe.yaml', @local_vars.to_yaml)
    end

    def load_vars
      @vars = File.exist?(File.expand_path('~/vars.rbe.yaml')) ? YAML::load_file(File.expand_path('~/vars.rbe.yaml')) : {}
    end

    def save_vars
      IO.write(File.expand_path('~/vars.rbe.yaml'), @vars.to_yaml)
    end

    def get(var_name, prompt_if_missing_required = false, default = nil)
      required = var_name[0] == '#'
      var_name = var_name[1..-1] if required
      if var_name != '_' && self.temp_vars.has_key?(var_name)
        self.temp_vars[var_name]
      elsif var_name != '_' && !var_name.start_with?('_') && has_key?(var_name)
        v = self[var_name]
        v.is_a?(Array) ? v.join(' ') : v
      elsif default
        self.temp_vars[var_name] = default
        default
      elsif required && prompt_if_missing_required
        v = Readline.readline("#{var_name} (press ENTER to cancel): ")
        if v.nil? || v.empty?
          exit 1
        else
          self.temp_vars[var_name] = v
          get("##{var_name}", true)
        end
      elsif required
        "{{##{var_name}}}"
      else
        nil
      end
    end

    def [](var_name)
      (@local_vars.has_key?(var_name) && @search_local) ? @local_vars[var_name] : @vars[var_name]
    end

    def []=(var_name, value)
      if var_name == '_'
        puts '_ is a reserved variable name'
        exit 1
      elsif (var_name =~ /^[\w\d]+$/).nil?
        puts "#{var_name} is not a valid variable name.  Variable names can only contain letters, numbers, and the underscore character."
        exit 1
      elsif var_name.start_with?('_')
        puts 'Variables starting with an underscore are temporary variables only'
        exit 1
      elsif save_local
        @local_vars[var_name] = value
        save_local_vars
      else
        @vars[var_name] = value
        save_vars
      end
    end

    def has_key?(var_name)
      @local_vars.has_key?(var_name) || @vars.has_key?(var_name)
    end

    def keys
      (@local_vars.keys + @vars.keys).uniq
    end

    def delete(var_name)
      if save_local
        @local_vars.delete(var_name)
        save_local_vars
      else
        @vars.delete(var_name)
        save_vars
      end
    end

    protected :load_vars, :save_vars, :load_local_vars, :save_local_vars
  end
end