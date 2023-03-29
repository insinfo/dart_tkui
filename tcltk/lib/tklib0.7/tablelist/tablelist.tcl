#==============================================================================
# Main Tablelist package module.
#
# Copyright (c) 2000-2021  Csaba Nemethi (E-mail: csaba.nemethi@t-online.de)
#==============================================================================

package require Tk 8
package require -exact tablelist::common 6.16

package provide tablelist $::tablelist::version
package provide Tablelist $::tablelist::version

::tablelist::useTile 0
::tablelist::createBindings
