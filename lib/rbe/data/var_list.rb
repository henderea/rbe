require 'yaml'

module Rbe::Data
  class VarList
    def initialize
      load_vars
    end

    def temp_vars
      @temp_vars ||= {}
    end

    def load_vars
      @vars = File.exist?(File.expand_path('~/vars.rbe.yaml')) ? YAML::load_file(File.expand_path('~/vars.rbe.yaml')) : {}
    end

    def save_vars
      IO.write(File.expand_path('~/vars.rbe.yaml'), @vars.to_yaml)
    end

    def get(var_name)
      if self.temp_vars.has_key?(var_name)
        self.temp_vars[var_name]
      elsif has_key?(var_name)
        self[var_name]
      else
        nil
      end
    end

    def [](var_name)
      @vars[var_name]
    end

    def []=(var_name, value)
      @vars[var_name] = value
      save_vars
    end

    def has_key?(var_name)
      @vars.has_key?(var_name)
    end

    def keys
      @vars.keys
    end

    def delete(var_name)
      @vars.delete(var_name)
      save_vars
    end

    protected :load_vars, :save_vars
  end
end