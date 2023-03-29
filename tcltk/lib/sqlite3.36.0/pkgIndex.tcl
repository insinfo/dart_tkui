#
# Tcl package index file
#
# Note sqlite*3* init specifically
#
package ifneeded sqlite3 3.36.0 \
    [list load [file join $dir sqlite3360.dll] Sqlite3]
