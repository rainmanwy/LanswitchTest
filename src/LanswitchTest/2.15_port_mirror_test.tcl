source pkgIndex.tcl

package require StcLib
package require SpirentTestCenter


#被镜像端口列表
#光口: EthernetFiber, 电口：EthernetCopper
#端口速率:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
set PORT_LIST {
    { //192.168.0.100/3/1 EthernetFiber SPEED_1G } 
	{ //192.168.0.100/3/2 EthernetFiber SPEED_1G } 
}

#镜像端口列表
set MIRROR_PORT_LIST {
    { //192.168.0.100/3/3 EthernetFiber SPEED_1G } 
    { //192.168.0.100/3/4 EthernetFiber SPEED_1G } 
}
#测试时长
set DURATION 30


#mac地址绑定测试
proc main { } {
    global PORT_LIST
    global MIRROR_PORT_LIST
    global DURATION

    set port_object_list [init_env $PORT_LIST]
    set mirror_port_object_list [init_env $MIRROR_PORT_LIST]

    set stream_block_list [init_fullmesh_stream $port_object_list 64]
    set generator_list [init_generator_with_duration $port_object_list 1 25 "START_OF_FRAME"]
    set analyzer_list [init_analyzer $port_object_list]
    set mirror_analyzer_list [init_analyzer $mirror_port_object_list]

    # mac learn
    start_generator_list $generator_list
    stc::sleep 5
    stc::perform generatorStop -generatorList $generator_list
    stc::perform analyzerStop -analyzerList $analyzer_list
    stc::perform analyzerStop -analyzerList $mirror_analyzer_list
    clear_all_results $port_object_list
    clear_all_results $mirror_port_object_list
    stc::sleep 2
    stc::apply   
    
    puts "Test port mirror with duration $DURATION"
    set rx_result_list [create_rx_statistic_handler $port_object_list]
    set tx_result_list [create_tx_statistic_handler $port_object_list]
    set mirror_rx_result_list [create_rx_statistic_handler $mirror_port_object_list]
    stc::sleep 3
    init_generator_with_duration $port_object_list $DURATION 25
    stc::sleep 2
    # 运行analyzer和generator
    start_analyzer_list $analyzer_list
    start_analyzer_list $mirror_analyzer_list
    stc::sleep 3
    start_generator_list $generator_list
    stc::sleep 2
    stc::sleep $DURATION
    stc::sleep 3
    stc::perform generatorStop -generatorList $generator_list
    stc::sleep 3

    puts "Mirror ports results:"
    foreach var1 $rx_result_list var2 $tx_result_list var3 $port_object_list {
        array set rx_counts [stc::get $var1]
        array set tx_counts [stc::get $var2]
        # set tx_frame_count [expr $tx_frame_count + $tx_counts(-GeneratorFrameCount)]
        # set rx_frame_count [expr $rx_frame_count + $rx_counts(-SigFrameCount)]
        set location [stc::get $var3 -location]
        # parray rx_counts
        # parray tx_counts
        puts "Port: $location  Send frame:  $tx_counts(-GeneratorFrameCount), Receive sig frame:  $rx_counts(-SigFrameCount), Recive total frame: $rx_counts(-TotalFrameCount)"
    }

    puts "Monitor ports results:"
    foreach var1 $mirror_rx_result_list var2 $mirror_port_object_list {
        array set rx_counts [stc::get $var1]
        # set rx_frame_count [expr $rx_frame_count + $rx_counts(-SigFrameCount)]
        set location [stc::get $var2 -location]
        # parray rx_counts
        # parray tx_counts
        puts "Port: $location  Receive sig frame:  $rx_counts(-SigFrameCount), Recive total frame: $rx_counts(-TotalFrameCount)"
    }
    
    stc::perform analyzerStop -analyzerList $analyzer_list
    stc::perform analyzerStop -analyzerList $mirror_analyzer_list
    # array set result_view [stc::get $jitter_result_view]
    # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count, Average jitter: $result_view(-AvgJitter), Max jitter: $result_view(-MaxJitter), Min jitter: $result_view(-MinJitter)"
    clear_all_results $port_object_list 
    clear_all_results $mirror_port_object_list

    release_env
}

main

