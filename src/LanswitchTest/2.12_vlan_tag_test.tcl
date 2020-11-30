source pkgIndex.tcl

package require StcLib
package require SpirentTestCenter


#光口: EthernetFiber, 电口：EthernetCopper
#端口速率:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
set PORT_LIST {
    { //192.168.0.100/3/1 EthernetFiber SPEED_1G } 
	{ //192.168.0.100/3/2 EthernetFiber SPEED_1G } 
	{ //192.168.0.100/3/3 EthernetFiber SPEED_1G } 
	{ //192.168.0.100/3/4 EthernetFiber SPEED_1G } 
}

#测试时长
set DURATION 30


proc main { } {
    global PORT_LIST
    global DURATION

    set stream_name(1) "GOOSE NO VID"
    set stream_name(2) "GOOSE VID1"
    set stream_name(3) "GOOSE VID10"
    set stream_name(4) "GOOSE VID20"
    set stream_name(5) "IPV4 NO VID"
    set stream_name(6) "IPV4 VID1"
    set stream_name(7) "IPV4 VID10"
    set stream_name(8) "IPV4 VID20"
    set stream_name(9) "BROADCAST NO VID"

    set port_object_list [init_env $PORT_LIST]
    lappend tx_port_list [lindex $port_object_list 0]

    set stream_block_list [init_2_12_stream [lindex $port_object_list 0]]

    set generator_list [init_generator_with_duration $tx_port_list $DURATION 100 "START_OF_FRAME"]
    set analyzer_list [init_analyzer $port_object_list]
    config_result_view_mode JITTER
    
    puts "Test vlan tag functionality with duration $DURATION"
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
}

main

