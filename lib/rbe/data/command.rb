module Rbe::Data
  class Command
    attr_reader :data_hash, :list, :name

    attr_accessor :sudo_override, :silent, :local, :should_loop

    class << self
      def prop(*fields, &get_block)
        get_block = ->(_, _, dv) { dv } unless get_block
        @props ||= []
        fields.each { |field|
          @props << field.to_sym
          self.create_method(field.to_sym) { get_block.call(self, field.to_sym, self[field.to_sym]) }
          self.create_method("#{field.to_s}=".to_sym) { |value| self[field.to_sym] = value }
        }
        @props.uniq!
      end

      def validate!(hash)
        hash && hash.is_a?(Hash) && @props.all? { |p| hash.has_key?(p) }
      end

      protected :prop
    end

    protected :list

    prop(:command, :sudo, :args, :vars) { |command, field, data_value|
      if field == :sudo && command.sudo_override
        command.sudo_override
      else
        data_value
      end
    }

    def initialize(name, list, data_hash, local = false)
      raise ArgumentError, 'Invalid data hash' unless Rbe::Data::Command.validate!(data_hash)
      @name      = name
      @list      = list
      @data_hash = data_hash
      @local     = local
    end

    def [](key)
      self.data_hash[key.to_sym]
    end

    def []=(key, value)
      self.data_hash[key.to_sym] = value
      self.list.update_command(self.name, self.data_hash, self.local)
    end

    def delete(key)
      self.data_hash.delete(key.to_sym)
      self.list.update_command(self.name, self.data_hash, self.local)
    end
  end
end