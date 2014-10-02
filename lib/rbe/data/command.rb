module Rbe::Data
  class Command
    attr_reader :data_hash, :list, :name

    attr_accessor :sudo_override, :silent

    class << self
      def prop(*fields, &get_block)
        @props ||= []
        fields.each { |field|
          @props << field.to_sym
          self.create_method(field.to_sym) {
            data_value = self[field.to_sym]
            if get_block
              get_block.call(self, field.to_sym, data_value)
            else
              data_value
            end
          }
          self.create_method("#{field.to_s}=".to_sym) { |value| self[field.to_sym] = value }
        }
        @props.uniq!
      end

      def validate!(hash)
        hash && hash.is_a?(Hash) && @props.all? { |p| hash.has_key?(p) }
      end

      # def ro_prop(*fields)
      #   fields.each { |field|
      #     self.create_method(field.to_sym) { self[field.to_sym] }
      #   }
      # end

      protected :prop
    end

    protected :list

    prop(:command, :sudo, :args) { |command, field, data_value|
      if field == :sudo && command.sudo_override
        command.sudo_override
      else
        data_value
      end
    }

    def initialize(name, list, data_hash)
      raise ArgumentError, 'Invalid data hash' unless Rbe::Data::Command.validate!(data_hash)
      @name      = name
      @list      = list
      @data_hash = data_hash
    end

    def [](key)
      self.data_hash[key.to_sym]
    end

    def []=(key, value)
      self.data_hash[key.to_sym] = value
      self.list.update_command(self.name, self.data_hash)
    end

    def delete(key)
      self.data_hash.delete(key.to_sym)
      self.list.update_command(self.name, self.data_hash)
    end
  end
end