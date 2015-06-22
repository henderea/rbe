require 'yaml'
require_relative 'abstract_list'

module Rbe::Data
  class AliasList
    attr_reader :list

    def initialize
      load_list
    end

    def file_name
      'aliases.rbe.yaml'
    end

    def load_list
      @list = File.exist?(File.expand_path("~/#{self.file_name}")) ? YAML::load_file(File.expand_path("~/#{self.file_name}")) : []
    end

    def save_list
      IO.write(File.expand_path("~/#{self.file_name}"), @list.to_yaml) unless @no_save
    end

    def <<(alias_name)
      @list << alias_name
      @list = @list.uniq
      save_list
    end

    def delete(alias_name)
      @list.delete(alias_name)
      save_list
    end

    def no_save
      @no_save = true
      yield
      @no_save = false
    end
  end
end