require 'readline'
require 'io/console'
require 'yaml'

module Rbe
  class IO
    class << self
      def input_stream
        @input_stream || $stdin
      end

      def input_stream=(input_stream)
        @input_stream = input_stream
      end

      def output_stream
        @output_stream || $stdout
      end

      def output_stream=(output_stream)
        @output_stream = output_stream
      end

      def error_stream
        @error_stream || $stderr
      end

      def error_stream=(error_stream)
        @error_stream = error_stream
      end

      def gets
        self.input_stream.gets
      end

      def readline(prompt = '', add_hist = false)
        Readline.input  = self.input_stream
        Readline.output = self.output_stream
        Readline.readline(prompt, add_hist)
      end

      def print(*obj)
        self.output_stream.print(*obj)
      end

      def puts(*obj)
        self.output_stream.puts(*obj)
      end

      def print_error(*obj)
        self.error_stream.print(*obj)
      end

      def puts_error(*obj)
        self.error_stream.puts(*obj)
      end

      def no_echo(&block)
        self.input_stream.noecho(&block)
      end

      def read_yaml(filename, default = nil)
        File.exist?(File.expand_path(filename)) ? YAML::load_file(File.expand_path(filename)) : default
      end

      def write_yaml(filename, obj)
        ::IO.write(File.expand_path(filename), obj.to_yaml)
      end

      def exit(status = true)
        Process.exit(status)
      end
    end
  end
end