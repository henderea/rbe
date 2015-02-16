require 'everyday_natsort_kernel'
require 'yaml'
require_relative 'command'
require_relative 'abstract_list'

module Rbe::Data
  class CommandList < Rbe::Data::AbstractList
    def on_init
      migrate
    end

    def local_list
      @local_commands
    end

    def local_list=(local_list)
      @local_commands = local_list
    end

    def list
      @commands
    end

    def list=(list)
      @commands = list
    end

    def file_name
      'commands.rbe.yaml'
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
      save_list if changed
      @commands
    end

    def update_command(name, data_hash, local)
      if local
        @local_commands[name] = data_hash
        save_local_list
      else
        @commands[name] = data_hash
        save_list
      end
    end

    def command(cmd_id)
      self.command2(cmd_id)
    end

    def command2(cmd_id, sc = nil, sl = nil, loop = false)
      get_normal(cmd_id, sc, sl, loop) ||
          get_plus_sl(cmd_id, sc, sl, loop) ||
          get_plus_nsl(cmd_id, sc, sl, loop) ||
          get_plus_loop(cmd_id, sc, sl, loop) ||
          get_sl(cmd_id, sc, sl, loop) ||
          get_nsl(cmd_id, sc, sl, loop) ||
          get_loop(cmd_id, sc, sl, loop) ||
          get_s(cmd_id, sc, sl, loop) ||
          get_rs(cmd_id, sc, sl, loop) ||
          nil
    end

    def get_normal(cmd_id, sc, sl, loop)
      has_key?(cmd_id) && -> {
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
      }.call
    end

    def get_plus_sl(cmd_id, sc, sl, loop)
      has_key?("#{cmd_id}_sl") && command2("#{cmd_id}_sl", sc, true, loop)
    end

    def get_plus_nsl(cmd_id, sc, sl, loop)
      has_key?("#{cmd_id}_nsl") && command2("#{cmd_id}_nsl", sc, false, loop)
    end

    def get_plus_loop(cmd_id, sc, sl, loop)
      has_key?("#{cmd_id}_loop") && command2("#{cmd_id}_loop", sc, sl, true)
    end

    def get_sl(cmd_id, sc, sl, loop)
      cmd_id.end_with?('_sl') && command2(cmd_id[0..-4], sc, true, loop)
    end

    def get_nsl(cmd_id, sc, sl, loop)
      cmd_id.end_with?('_nsl') && command2(cmd_id[0..-5], sc, false, loop)
    end

    def get_loop(cmd_id, sc, sl, loop)
      cmd_id.end_with?('_loop') && command2(cmd_id[0..-6], sc, sl, true)
    end

    def get_s(cmd_id, sc, sl, loop)
      cmd_id.end_with?('_s') && command2(cmd_id[0..-3], 'sudo', sl, loop)
    end

    def get_rs(cmd_id, sc, sl, loop)
      cmd_id.end_with?('_rs') && command2(cmd_id[0..-4], 'rvmsudo', sl, loop)
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
      cl = save_local ? @local_commands : @commands
      if value.is_a?(Rbe::Data::Command)
        cl[key] = value.data_hash
      elsif value.is_a?(Hash) && Rbe::Data::Command.validate!(value)
        cl[key] = value
      else
        raise ArgumentError, 'Invalid data input'
      end
      save_local ? save_local_list : save_list
    end

    def delete(key)
      if save_local
        @local_commands.delete(key)
        save_local_list
      else
        @commands.delete(key)
        save_list
      end
    end

    protected :migrate, :command2, :list, :local_list, :list=, :local_list=, :on_init, :get_normal, :get_plus_sl, :get_plus_nsl, :get_plus_loop, :get_sl, :get_nsl, :get_loop, :get_s, :get_rs
  end
end