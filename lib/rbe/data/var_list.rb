require 'everyday_natsort_kernel'
require 'yaml'
require 'readline'
require_relative 'abstract_list'

module Rbe::Data
  class VarList < Rbe::Data::AbstractList
    attr_accessor :search_local

    def on_init
      @search_local = true
    end

    def local_list
      @local_vars
    end

    def local_list=(local_list)
      @local_vars = local_list
    end

    def list
      @vars
    end

    def list=(list)
      @vars = list
    end

    def file_name
      'vars.rbe.yaml'
    end

    def write_vars
      save_list unless @vars.empty?
      save_local_list unless @local_vars.empty?
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

    def get(var_name, prompt_if_missing_required = false, default = nil)
      required = var_name[0] == '#'
      var_name = var_name[1..-1] if required
      get_temp_var(var_name) ||
          get_reg_var(var_name) ||
          get_default(var_name, default) ||
          get_required_prompt(var_name, required, prompt_if_missing_required) ||
          get_required(var_name, required) ||
          nil
    end

    def get_temp_var(var_name)
      var_name != '_' && self.temp_vars[var_name]
    end

    def get_reg_var(var_name)
      var_name != '_' && !var_name.start_with?('_') && has_key?(var_name) && -> {
        v = self[var_name]
        v.is_a?(Array) ? v.join(' ') : v
      }.call
    end

    def get_default(var_name, default)
      default && -> {
        self.temp_vars[var_name] = default
        default
      }.call
    end

    def get_required_prompt(var_name, required, prompt_if_missing_required)
      required && prompt_if_missing_required && -> {
        v = Readline.readline("#{var_name} (press ENTER to cancel): ")
        if v.nil? || v.empty?
          exit 1
        else
          self.temp_vars[var_name] = v
          get("##{var_name}", true)
        end
      }.call
    end

    def get_required(var_name, required)
      required && "{{##{var_name}}}"
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
        save_local_list
      else
        @vars[var_name] = value
        save_list
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
        save_local_list
      else
        @vars.delete(var_name)
        save_list
      end
    end

    protected :list, :local_list, :list=, :local_list=, :on_init, :get_temp_var, :get_reg_var, :get_default, :get_required_prompt, :get_required
  end
end