require 'rbe/version'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

global.helpers[:print_about_text] =-> {
  vnum = Rbe::VERSION
  base_str =  <<'EOS'


####################################################################################################
####################################################################################################
###                                                                                              ###
### +------------------------------+                                                             ###
### |       _  _   _  ___  _       | ###            +------------------------------+             ###
### | \  / |_ |_| |_   |  | | |\ | | ###            | By Eric Henderson (henderea) |             ###
### |  \/  |_ |\   _| _|_ |_| | \| | ###            +------------------------------+             ###
### |                              | ###                                                         ###
### |                              | ###           +---------------------------------+           ###
### |                              | ###           | https://github.com/henderea/rbe |           ###
### |                              | ###           +---------------------------------+           ###
### +------------------------------+ ###                                                         ###
###                                  ###                                                         ###
###     ###      ############        ###     ##########                    #########             ###
###     ###    ######      ####      ###  ####       #####              #####     #####          ###
###     ###  #####           ####    ######            #####         #####           #####       ###
###     ### ###               ###    ###                  ####     #####               #####     ###
###     #####                        ###                   ####   #####                 #####    ###
###     ####                         ###                    ###   ###########################    ###
###     ###                          ###                   ####   #####                          ###
###     ###                          ###                  ####     #####                  ###    ###
###     ###                          ####               ####         #####               ###     ###
###     ###                          ######          #####              #####         ####       ###
###     ###                          ###################                   ############          ###
###                                                                                              ###
###                                                                                              ###
####################################################################################################
####################################################################################################

EOS

  x_range = (5...35)
  y_range = (9..11)

  lines = base_str.lines

  chars = {
      '.' => [
          ' ',
          ' ',
          '.'
      ],
      '0' => [
          ' _ ',
          '| |',
          '|_|'
      ],
      '1' => [
          '   ',
          ' | ',
          ' | '
      ],
      '2' => [
          ' _ ',
          ' _|',
          '|_ '
      ],
      '3' => [
          ' _ ',
          ' _|',
          ' _|'
      ],
      '4' => [
          '   ',
          '|_|',
          '  |'
      ],
      '5' => [
          ' _ ',
          '|_ ',
          ' _|'
      ],
      '6' => [
          ' _ ',
          '|_ ',
          '|_|'
      ],
      '7' => [
          ' __',
          '  /',
          ' / '
      ],
      '8' => [
          ' _ ',
          '|_|',
          '|_|'
      ],
      '9' => [
          ' _ ',
          '|_|',
          ' _|'
      ]
  }

  vnum_lines = ['', '', '']

  vnum = vnum.to_s.gsub(/[^.0-9]/, '')

  (0...vnum.length).each { |i|
    c = vnum[i]
    d = chars[c.to_s]
    (0..2).each { |j|
      vnum_lines[j] << ' ' if i > 0
      vnum_lines[j] << d[j]
    }
  }

  length = vnum_lines[0].length

  x_range_size = x_range.size

  padding_start = ((x_range_size - length) / 2).floor
  padding_end   = x_range_size - length - padding_start

  (0..2).each { |i|
    vnum_lines[i] = "#{' ' * padding_start}#{vnum_lines[i]}#{' ' * padding_end}"
  }

  y_range.each { |i|
    j                 = i - y_range.begin
    lines[i][x_range] = vnum_lines[j]
  }

  puts lines.join('')

  puts "Installed at: #{$0}\n\n"
}