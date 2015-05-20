# Rbe

A tool for making it easier to run common commands.  Supports storing and automatically filling in your sudo password. Also supports saving common commands and calling them by name.  Groups of commands can also be saved and called by name.  Commands can take parameters and plug them into specific points in the command or just append them on the end.  Also supports a variable system that allows local and global variables, temporary variables, and required variables (which will ask for the value if it isn't already known).

## Installation

    gem sources -a https://repo.fury.io/henderea/
    gem install rbe

## Usage

TODO: Write usage instructions here

Until I get documentation written, use `rbe help` and related commands to see the help info.  You may need to look at the source code (<https://github.com/henderea/rbe>) to fully understand the utility.

---
###Working with sudo

`rbe` supports storing your password in the Mac OS X keychain for use in sudo commands.  `rbe auth` will prompt you for your sudo password and then store it securely in the Mac OS X keychain.

---
###Working with commands:

Commands are identified by a name, and have a shell command (does not support shell built-in commands).  Group commands are also identified by a name, but they can only contain a list of references to regular and/or group commands by name.

---

## Contributing

1. Fork it ( https://github.com/henderea/rbe/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
