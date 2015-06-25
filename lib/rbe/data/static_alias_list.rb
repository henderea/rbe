require 'everyday_natsort_kernel'
require 'yaml'
require_relative 'abstract_list'

module Rbe::Data
  class StaticAliasList < Rbe::Data::AbstractGlobalList
    def list
      @list
    end

    def list=(list)
      @list = list
    end

    def file_name
      'static-aliases.rbe.yaml'
    end

    def [](alias_name)
      @list[alias_name]
    end

    def []=(alias_name, value)
      @list[alias_name] = value
      save_list
    end

    def has_key?(alias_name)
      @list.has_key?(alias_name)
    end

    def keys
      @list.keys
    end

    def delete(alias_name)
      @list.delete(alias_name)
      save_list
    end

    def each(&block)
      @list.each(&block)
    end

    protected :list, :list=
  end
end