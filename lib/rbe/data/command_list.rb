require 'yaml'
require_relative 'command'

module Rbe::Data
  class CommandList
    def initialize
      load_commands
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
      }
      save_commands if changed
      @commands
    end

    def load_commands
      @commands = File.exist?(File.expand_path('~/commands.rbe.yaml')) ? YAML::load_file(File.expand_path('~/commands.rbe.yaml')) : {}
    end

    def save_commands
      IO.write(File.expand_path('~/commands.rbe.yaml'), @commands.to_yaml) unless @no_save
    end

    def update_command(name, data_hash)
      @commands[name] = data_hash
      save_commands
    end

    def command(cmd_id)
      self.command2(cmd_id)
    end

    def command2(cmd_id, sc = nil, sl = nil)
      if has_key?(cmd_id)
        if sl.nil?
          if cmd_id.end_with?('_sl')
            sl = true
          elsif cmd_id.end_with?('_nsl')
            sl = false
          end
        end
        # [sc || self.commands[cmd_id][:sudo], sl.nil? ? self.commands[cmd_id][:silent] : sl, self.commands[cmd_id]]
        # { sudo: sc, silent: sl, command: self[cmd_id] }
        cmd = self[cmd_id]
        cmd.sudo_override = sc
        cmd.silent = sl
        cmd
      elsif has_key?("#{cmd_id}_sl")
        command2("#{cmd_id}_sl", sc, true)
      elsif has_key?("#{cmd_id}_nsl")
        command2("#{cmd_id}_nsl", sc, false)
      elsif cmd_id.end_with?('_sl')
        command2(cmd_id[0..-4], sc, true)
      elsif cmd_id.end_with?('_nsl')
        command2(cmd_id[0..-5], sc, false)
      elsif cmd_id.end_with?('_s')
        command2(cmd_id[0..-3], 'sudo', sl)
      elsif cmd_id.end_with?('_rs')
        command2(cmd_id[0..-4], 'rvmsudo', sl)
      else
        nil
      end
    end

    def has_key?(key)
      @commands.has_key?(key)
    end

    def keys
      @commands.keys
    end

    def [](key)
      val = @commands[key]
      if val
        Rbe::Data::Command.new(key, self, val)
      else
        nil
      end
    end

    def []=(key, value)
      if value.is_a?(Rbe::Data::Command)
        @commands[key] = value.data_hash
      elsif value.is_a?(Hash) && Rbe::Data::Command.validate!(value)
        @commands[key] = value
      else
        raise ArgumentError, 'Invalid data input'
      end
      save_commands
    end

    def delete(key)
      @commands.delete(key)
      save_commands
    end

    def no_save
      @no_save = true
      yield
      @no_save = false
    end

    protected :save_commands, :load_commands, :migrate, :command2
  end
end