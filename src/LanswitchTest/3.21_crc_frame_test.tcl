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
	{ //192.168.0.100/3/5 EthernetFiber SPEED_1G } 
}

#测试时长
set DURATION 30


#数据帧过滤测试，包含源mac错误帧，FCS错误帧，mac地址冲突帧，正常帧
proc main { } {
    global PORT_LIST
    global DURATION

    set port_object_list [init_env $PORT_LIST]
    lappend tx_port_list [lindex $port_object_list 0]

    set stream_block_list [init_3_25_stream [lindex $port_object_list 0]]

    set generator_list [init_generator_with_duration $port_object_list $DURATION 25 "START_OF_FRAME"]
    set analyzer_list [init_analyzer $port_object_list]
    config_result_view_mode JITTER
    
    puts "Test crc frame with duration $DURATION"
    set jitter_result_view_list [config_jitter_result_view $stream_block_list]
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
    foreach var $jitter_result_view_list {
        set jitter [stc::get $var  -resultHandleList]
        array set jitter_counts [stc::get $jitter]
        parray jitter_counts
        puts "StreamBlock $index : RxPort: $jitter_counts(-RxPort),  Receive frame:  $jitter_counts(-FrameCount), Dropped frame:  $jitter_counts(-DroppedFrameCount), Dropped Percentage: $jitter_counts(-DroppedFramePercent)"
    }
    stc::perform analyzerStop -analyzerList $analyzer_list
    # array set result_view [stc::get $jitter_result_view]
    # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count, Average jitter: $result_view(-AvgJitter), Max jitter: $result_view(-MaxJitter), Min jitter: $result_view(-MinJitter)"
    clear_all_results $port_object_list  

    release_env
}

main

