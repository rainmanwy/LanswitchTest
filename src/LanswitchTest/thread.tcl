proc multi_thread_job {
    { job_cmds }
    { job_thread }
} {
    package require Thread
    package require Ttrace

    set tpool [tpool::create -maxworkers $job_thread]
    set puts_mutex [thread::mutex create]
    tsv::set tsv puts_mutex $puts_mutex

    ttrace::eval {
        proc exec_job {
            { job_cmd }
            { job_log }
        } {
            set stm [clock seconds]
            puts $job_cmd
            if { [catch {eval exec $job_cmd >& $job_log} msg] } {
                set etm [clock seconds]
                set puts_mutex [tsv::get tsv puts_mutex]
                thread::mutex lock $puts_mutex
                puts ""
                puts "========== JOB ERROR ============="
                puts "CMD: $job_cmd"
                puts "MSG: $msg"
                puts "LOG: $job_log"
                puts "RTM: [expr ($etm-$stm)/60]m [expr ($etm-$stm)%60]s"
                puts "=================================="
                thread::mutex unlock $puts_mutex
            } else {
                set puts_mutex [tsv::get tsv puts_mutex]
                thread::mutex lock $puts_mutex
                puts ""
                puts "========== JOB FINISHED =========="
                puts "CMD: $job_cmd"
                puts "LOG: $job_log"
                puts "RTM: [expr ($etm-$stm)/60]m [expr ($etm-$stm)%60]s"
                puts "=================================="
                thread::mutex unlock $puts_mutex
            }
        }
    }

    set job_idx 1
    file mkdir "./log"
    set tjobs ""
    foreach job_cmd $job_cmds {
        set job_log "./log/job_${job_idx}.log"
        incr job_idx

        lappend tjobs [tpool::post -nowait $tpool "
            package require Ttrace
            exec_job \"$job_cmd\" \"$job_log\"
        "]
    }

    foreach tjob $tjobs {
        tpool::wait $tpool $tjob
    }

    tpool::release $tpool
    thread::mutex destroy $puts_mutex
    tsv::unset tsv
}

set jobs {
    {sleep 1}
    {sleep 2}
    {sleep 3}
    {sleep 4}
    {sleep 5}
    {sleep 1}
    {sleep 2}
    {sleep 3}
    {sleep 4}
    {sleep 5}
}

multi_thread_job $jobs 5