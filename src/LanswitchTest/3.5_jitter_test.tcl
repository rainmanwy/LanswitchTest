source pkgIndex.tcl

package require StcLib
package require SpirentTestCenter


#光口: EthernetFiber, 电口：EthernetCopper
#端口速率:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
set PORT_LIST {
    { //192.168.0.100/3/5 EthernetFiber SPEED_1G } 
    { //192.168.0.100/3/6 EthernetFiber SPEED_1G } 
}

#帧长列表
set FRAME_LEN_LIST {64 1518}

#测试时长
set DURATION 60

# 负载列表
set LOAD_LIST {100}


proc main { } {
    global PORT_LIST
    global DURATION
    global FRAME_LEN_LIST
    global LOAD_LIST

    set port_object_list [init_env $PORT_LIST]
    set stream_block_list [init_stream $port_object_list]
    set generator_list [init_generator_with_duration $port_object_list 60 10 "START_OF_FRAME"]
    set analyzer_list [init_analyzer $port_object_list]
    config_result_view_mode JITTER

    foreach frame_length  $FRAME_LEN_LIST {
        foreach load $LOAD_LIST {
            puts "Test jitter with frame length $frame_length, load $load"
            set rx_result_list [create_rx_statistic_handler $port_object_list]
            set tx_result_list [create_tx_statistic_handler $port_object_list]
            set jitter_result_view_list [config_jitter_result_view $stream_block_list]
            set tx_stream_results [config_tx_stream_result_view $stream_block_list]
            stc::sleep 3
            # 配置包长和负载
            init_generator_with_duration $port_object_list $DURATION $load "START_OF_FRAME"
            config_stream_length_and_load $stream_block_list $frame_length $load
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

            set tx_frame_count 0
            set rx_frame_count 0
            foreach var1 $rx_result_list var2 $tx_result_list var3 $jitter_result_view_list var4 $port_object_list var5 $tx_stream_results {
                array set rx_counts [stc::get $var1]
                array set tx_counts [stc::get $var2]
                set jitter [stc::get $var3  -resultHandleList]
                set tx_result [stc::get $var5  -resultHandleList]
                set sumJitter [stc::get $jitter -SummaryResultChild]
                array set jitter_counts [stc::get $jitter]
                array set sum_jitter_counts [stc::get $sumJitter]
                array set st_tx_counts [stc::get $tx_result]
                # set tx_frame_count [expr $tx_frame_count + $tx_counts(-GeneratorFrameCount)]
                # set rx_frame_count [expr $tx_frame_count + $rx_counts(-TotalFrameCount)]
                set location [stc::get $var4 -location]
                # parray jitter_counts
                # parray sum_jitter_counts
                puts "Port: $location  Send frame:  $tx_counts(-GeneratorFrameCount), Receive frame:  $rx_counts(-TotalFrameCount)  MaxJitter: $jitter_counts(-MaxJitter)  MinJitter: $jitter_counts(-MinJitter)  AvgJitter: $jitter_counts(-AvgJitter)"
            }
            stc::perform analyzerStop -analyzerList $analyzer_list
            # array set result_view [stc::get $jitter_result_view]
            # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count, Average jitter: $result_view(-AvgJitter), Max jitter: $result_view(-MaxJitter), Min jitter: $result_view(-MinJitter)"
            clear_all_results $port_object_list  

            stc::sleep 10          
        }        
    }
    release_env
}

main

