if {![package vsatisfies [package provide Tcl] 8.5]} {return}
package ifneeded critcl::callback 1 [list ::apply {dir {
    source [file join $dir critcl-rt.tcl]
    set path [file join $dir [::critcl::runtime::MapPlatform]]
    set ext [info sharedlibextension]
    set lib [file join $path "callback$ext"]
    load $lib Callback
    package provide critcl::callback 1
}} $dir]
