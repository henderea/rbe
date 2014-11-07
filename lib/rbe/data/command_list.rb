require 'yaml'
require_relative 'command'

module Rbe::Data
  class CommandList
    attr_accessor :save_local

    def initialize
      @save_local = false
      load_commands
      load_local_commands
      migrate
    end

    def migrate
      changed = false
      @commands.each_key { |k|
        sudo = @commands[k][:sudo]
        if sudo.is_a?(TrueClass)
          changed             = true
          @commands[k][:sudo] = 'sudo'
        elsif sudo.is_a?(FalseClass)
          changed             = true
          @commands[k][:sudo] = nil
        end
        unless @commands[k].has_key?(:vars)
          changed             = true
          @commands[k][:vars] = nil
        end
      }
      save_commands if changed
      @commands
    end

    def load_local_commands
      @local_commands = File.exist?('commands.rbe.yaml') ? YAML::load_file('commands.rbe.yaml') : {}
    end

    def save_local_commands
      IO.write('commands.rbe.yaml', @local_commands.to_yaml) unless @no_save
    end

    def load_commands
      @commands = File.exist?(File.expand_path('~/commands.rbe.yaml')) ? YAML::load_file(File.expand_path('~/commands.rbe.yaml')) : {}
    end

    def save_commands
      IO.write(File.expand_path('~/commands.rbe.yaml'), @commands.to_yaml) unless @no_save
    end

    def update_command(name, data_hash, local)
      if local
        @local_commands[name] = data_hash
        save_local_commands
      else
        @commands[name] = data_hash
        save_commands
      end
    end

    def command(cmd_id)
      self.command2(cmd_id)
    end

    def command2(cmd_id, sc = nil, sl = nil, loop = false)
      if has_key?(cmd_id)
        if sl.nil?
          if cmd_id.end_with?('_sl')
            sl = true
          elsif cmd_id.end_with?('_nsl')
            sl = false
          end
        end
        loop              ||= cmd_id.end_with?('_loop')
        cmd               = self[cmd_id]
        cmd.sudo_override = sc
        cmd.silent        = sl
        cmd.should_loop   = loop
        cmd
      elsif has_key?("#{cmd_id}_sl")
        command2("#{cmd_id}_sl", sc, true, loop)
      elsif has_key?("#{cmd_id}_nsl")
        command2("#{cmd_id}_nsl", sc, false, loop)
      elsif has_key?("#{cmd_id}_loop")
        command2("#{cmd_id}_loop", sc, sl, true)
      elsif cmd_id.end_with?('_sl')
        command2(cmd_id[0..-4], sc, true, loop)
      elsif cmd_id.end_with?('_nsl')
        command2(cmd_id[0..-5], sc, false, loop)
      elsif cmd_id.end_with?('_loop')
        command2(cmd_id[0..-6], sc, sl, true)
      elsif cmd_id.end_with?('_s')
        command2(cmd_id[0..-3], 'sudo', sl, loop)
      elsif cmd_id.end_with?('_rs')
        command2(cmd_id[0..-4], 'rvmsudo', sl, loop)
      else
        nil
      end
    end

    def has_key?(key)
      @local_commands.has_key?(key) || @commands.has_key?(key)
    end

    def keys
      (@local_commands.keys + @commands.keys).uniq
    end

    def [](key)
      val = @local_commands[key]
      if val
        local = true
      else
        val   = @commands[key]
        local = false
      end
      if val
        Rbe::Data::Command.new(key, self, val, local)
      else
        nil
      end
    end

    def []=(key, value)
      if save_local
        if value.is_a?(Rbe::Data::Command)
          @local_commands[key] = value.data_hash
        elsif value.is_a?(Hash) && Rbe::Data::Command.validate!(value)
          @local_commands[key] = value
        else
          raise ArgumentError, 'Invalid data input'
        end
        save_local_commands
      else
        if value.is_a?(Rbe::Data::Command)
          @commands[key] = value.data_hash
        elsif value.is_a?(Hash) && Rbe::Data::Command.validate!(value)
          @commands[key] = value
        else
          raise ArgumentError, 'Invalid data input'
        end
        save_commands
      end
    end

    def delete(key)
      if save_local
        @local_commands.delete(key)
        save_local_commands
      else
        @commands.delete(key)
        save_commands
      end
    end

    def no_save
      @no_save = true
      yield
      @no_save = false
    end

    protected :save_commands, :load_commands, :save_local_commands, :load_local_commands, :migrate, :command2
  end
end