# 对头阻塞测试
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

#帧长列表
set FRAME_LEN_LIST {64}

#测试时长
set DURATION 30

proc check_port_num {port_list} {
    if { [llength $port_list] != 4 } {
        puts "Should select 4 ports, but select [llength $port_list]"
        exit 1
    }
}


proc main { } {
    global PORT_LIST
    global DURATION
    global FRAME_LEN_LIST

    # create port
    set port_object_list [init_env $PORT_LIST]
    lappend pair_port_list [lindex $port_object_list 0]
    lappend pair_port_list [lindex $port_object_list 1]
    set third_port [lindex $port_object_list 2]

    set fourth_port [lindex $port_object_list 3]
    
    set pair_stream_block_list [init_fullmesh_stream $pair_port_list 64 100]
    set third_stream_block1 [init_single_stream $third_port [lindex $pair_port_list 1] 64 50]
    set third_stream_block2 [init_single_stream $third_port $fourth_port 64 50]
    set fourth_stream_block [init_single_stream $fourth_port $third_port 64 100]

    set all_stream_block_list {}
    foreach var $pair_stream_block_list {
        lappend all_stream_block_list $var
    }
    lappend all_stream_block_list $third_stream_block1
    lappend all_stream_block_list $third_stream_block2

    set generator_list [init_generator_with_duration $port_object_list 1 100]
    set analyzer_list [init_analyzer $port_object_list]
    lappend actual_generator_list [lindex $generator_list 0]
    lappend actual_generator_list [lindex $generator_list 1]
    lappend actual_generator_list [lindex $generator_list 2]

    # learning
    start_generator_list $generator_list
    stc::sleep 5
    stc::perform generatorStop -generatorList $generator_list
    stc::perform analyzerStop -analyzerList $analyzer_list
    stc::sleep 3
    clear_all_results $port_object_list
    stc::sleep 2
    stc::apply          

    foreach frame_length  $FRAME_LEN_LIST {
        puts "Test HOL blocking with frame length $frame_length, duration $DURATION"
        
        # start testing
        set rx_stream_result_list [config_jitter_result_view $all_stream_block_list]
        stc::sleep 3
        # 配置包长和负载
        init_generator_with_duration $pair_port_list $DURATION 100
        config_stream_length_and_load $all_stream_block_list $frame_length 100
        stc::sleep 2
        # 运行analyzer和generator
        
        start_analyzer_list $analyzer_list
        stc::sleep 3
        start_generator_list $actual_generator_list
        
        stc::sleep 2
        stc::sleep $DURATION
        stc::sleep 3
        stc::perform generatorStop -generatorList $actual_generator_list       
        stc::sleep 2
        refresh_result_view $rx_stream_result_list 2 

        set fourth_rx_stream [stc::get [lindex $rx_stream_result_list 3]  -resultHandleList] 
        array set fourth_rx_stream_counts [stc::get $fourth_rx_stream]
        # foreach var $rx_stream_result_list {
        #     set rx_stream [stc::get $var  -resultHandleList]
        #     array set rx_stream_counts [stc::get $rx_stream]
            
        #     puts "Port: $location  Send frame:  $tx_counts(-GeneratorFrameCount), Receive sig frame:  $rx_counts(-SigFrameCount), Recive total frame: $rx_counts(-TotalFrameCount)"
        # }
        parray fourth_rx_stream_counts
        puts "Dropped Frame Percentage: $fourth_rx_stream_counts(-DroppedFramePercent), Total Received Frame: $fourth_rx_stream_counts(-FrameCount)"

        stc::perform analyzerStop -analyzerList $analyzer_list
        clear_all_results $port_object_list
        stc::sleep 10           
    }
    release_env
}

main

