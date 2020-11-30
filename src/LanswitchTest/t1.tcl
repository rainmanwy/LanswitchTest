if {[catch {



} msg]} {
    release_env
    einfo $msg
} 