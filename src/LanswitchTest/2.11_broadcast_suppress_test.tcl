
#光口: EthernetFiber, 电口：EthernetCopper
#端口速率:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
# set PORT_LIST {
    # { //192.168.0.100/3/5 EthernetFiber SPEED_1G } 
	# { //192.168.0.100/3/6 EthernetFiber SPEED_1G } 
# }

set FRAME_LENGTH 512
set LOAD 10

set PORT_LIST [lrange $configStr 0 1]

#广播抑制测试
proc main { } {
if {[catch {
    global PORT_LIST
    global DURATION
    global FRAME_LENGTH
    global LOAD

    set stream_name(1) "Stream(multicast)"
    set stream_name(2) "Stream(unicast)"
    set stream_name(3) "Stream(broadcast)"
    set stream_name(4) "Stream(unicast known)"

    set port_object_list [init_env $PORT_LIST]
    lappend tx_port_list [lindex $port_object_list 0]

    lappend learn_port_list [lindex $port_object_list 1]
    set learn_stream_list [init_2_11_learn_stream [lindex $port_object_list 1]]

    set stream_block_list [init_2_11_stream [lindex $port_object_list 0] $FRAME_LENGTH]

    set learn_generator_list [init_generator_with_duration $learn_port_list 1 10 "START_OF_FRAME"]
    set generator_list [init_generator_with_duration $tx_port_list $DURATION $LOAD "START_OF_FRAME"]
    set analyzer_list [init_analyzer $port_object_list]
    config_result_view_mode JITTER

    # mac learn
    start_generator_list $learn_generator_list
    stc::sleep 5
    stc::perform generatorStop -generatorList $learn_generator_list
    stc::perform analyzerStop -analyzerList $analyzer_list
    clear_all_results $port_object_list
    stc::sleep 2
    stc::apply   
    
    puts "Test broadcast suppression with duration $DURATION"
    set jitter_result_view_list [config_jitter_result_view $stream_block_list]
    set tx_stream_results [config_tx_stream_result_view $stream_block_list]
    stc::sleep 3
    # 运行analyzer和generator
    start_analyzer_list $analyzer_list
    stc::sleep 3
    start_generator_list $generator_list
    stc::sleep 2
    stc::sleep $DURATION
    stc::sleep 3
    stc::perform generatorStop -generatorList $generator_list
    stc::sleep 3
    refresh_result_view $jitter_result_view_list 2
    refresh_result_view $tx_stream_results 2

    set index 1
    foreach var1 $jitter_result_view_list var2 $tx_stream_results {
        set jitter [stc::get $var1  -resultHandleList]
        set tx_result [stc::get $var2  -resultHandleList]
        array set jitter_counts [stc::get $jitter]
        array set tx_counts [stc::get $tx_result]
        # parray jitter_counts
        puts "$stream_name($index): TxPort: [lindex [lindex $PORT_LIST 0] 0], RxPort: $jitter_counts(-RxPort),  Send frame: $tx_counts(-FrameCount), Receive frame:  $jitter_counts(-FrameCount)"
        set index [expr $index+1]
    }
    stc::perform analyzerStop -analyzerList $analyzer_list
    # array set result_view [stc::get $jitter_result_view]
    # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count, Average jitter: $result_view(-AvgJitter), Max jitter: $result_view(-MaxJitter), Min jitter: $result_view(-MinJitter)"
    clear_all_results $port_object_list  

    release_env

} msg]} {
    release_env
    einfo $msg
}    
}

main

