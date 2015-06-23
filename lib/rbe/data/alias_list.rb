require 'yaml'
require_relative 'abstract_global_flat_list'

module Rbe::Data
  class AliasList < Rbe::Data::AbstractGlobalFlatList
    def file_name
      'aliases.rbe.yaml'
    end

    def list
      @list
    end

    def list=(list)
      @list = list
    end

    def include?(alias_name)
      @list.include?(alias_name)
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
  end
end