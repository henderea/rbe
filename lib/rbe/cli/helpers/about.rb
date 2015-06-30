require 'rbe/version'

require 'everyday_thor_util/builder'
include EverydayThorUtil::Builder

global.helpers[:print_about_text] =-> {
  version_str = "Version #{Rbe::VERSION}"
  version_str2 = "| #{version_str} |".center(22)
  border = "+-#{'-' * version_str.length}-+".center(22)
  puts <<EOS


################################################################
################################################################
###                                                          ###
####{      border       }##   By Eric Henderson (henderea)   ###
####{   version_str2    }##                                  ###
####{      border       }## https://github.com/henderea/rbe  ###
###                      ##                                  ###
###    ##   ######       ## #######          #########       ###
###    ## ###    ###     ####    ####      ####     ####     ###
###    ####       ##     ##       ###     ###         ###    ###
###    ###               ##        ##     ###############    ###
###    ##                ##       ###     ###                ###
###    ##                ####   ####       ####      ####    ###
###    ##                #########           ##########      ###
###                                                          ###
################################################################
################################################################

Installed at: #{$0}

EOS
}