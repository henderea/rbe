require 'everyday-plugins'

module Rbe::Cli::Commands
  class Path
    extend Plugin

    register(:command, id: :path, parent: nil, name: 'path', short_desc: 'path', desc: 'print out the path of the current file') { puts __FILE__ }
  end
end