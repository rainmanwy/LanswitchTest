source pkgIndex.tcl

package require StcLib
package require SpirentTestCenter


#光口: EthernetFiber, 电口：EthernetCopper
#端口速率:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
set PORT_LIST {
    { //192.168.0.100/3/1 EthernetFiber SPEED_1G } 
    { //192.168.0.100/3/2 EthernetFiber SPEED_1G }    
}

#帧长列表
set FRAME_LEN_LIST {64 65 128}

#测试时长
set DURATION 1

# 负载列表
set LOAD_LIST {10 95}

#测试项序号，固定值
set TestIndex T3_4

set t3_4_result 1
set ValueList "#####$TestIndex,0001, {"


proc main { } {
    global PORT_LIST
    global DURATION
    global FRAME_LEN_LIST
    global LOAD_LIST
    global TestIndex
    global t3_4_result

    
    #输出运行状态信息
    puts "@@@@@$TestIndex, 初始化设置"

    set port_object_list [init_env $PORT_LIST]
    puts $port_object_list
    set stream_block_list [init_stream $port_object_list]
    set generator_list [init_generator_with_duration $port_object_list $DURATION 10 "END_OF_FRAME"]
    set analyzer_list [init_analyzer $port_object_list]
    config_result_view_mode  HISTOGRAM

    #输出运行状态信息
    puts "@@@@@$TestIndex, 开始测试"

    foreach frame_length  $FRAME_LEN_LIST {
        foreach load $LOAD_LIST {
            puts "Test latency with frame length $frame_length, load $load, duration $DURATION"
            puts "@@@@@$TestIndex, 测试帧长 $frame_length 字节, 测试负载 $load\%, 测试时间 $DURATION 秒" 
            set rx_result_list [create_rx_statistic_handler $port_object_list]
            set tx_result_list [create_tx_statistic_handler $port_object_list]
            set latency_result_view_list [config_avg_latency_result_view $port_object_list]
            stc::sleep 3
            # 配置包长和负载
            init_generator_with_duration $port_object_list $DURATION $load "END_OF_FRAME"
            config_stream_length_and_load $stream_block_list $frame_length
            # 运行analyzer和generator
            start_analyzer_list $analyzer_list
            stc::sleep 3
            start_generator_list $generator_list
            stc::sleep 2
            stc::sleep $DURATION
            stc::sleep 2
            stc::perform generatorStop -generatorList $generator_list
            stc::perform analyzerStop -analyzerList $analyzer_list
            stc::sleep 3
            refresh_result_view $latency_result_view_list 2

            # set tx_frame_count 0
            # set rx_frame_count 0
            foreach var1 $rx_result_list var2 $tx_result_list var3 $latency_result_view_list var4 $port_object_list {
                array set rx_counts [stc::get $var1]
                array set tx_counts [stc::get $var2]
                array set latency_counts [stc::get $var3]
                # set tx_frame_count [expr $tx_frame_count + $tx_counts(-GeneratorFrameCount)]
                # set rx_frame_count [expr $rx_frame_count + $rx_counts(-TotalFrameCount)]
                set location [stc::get $var4 -location]
                puts "Port: $location  Send frame:  $tx_counts(-GeneratorFrameCount), Receive frame:  $rx_counts(-TotalFrameCount)  AvgLatency: $latency_counts(-AvgLatency)  MaxLatency: $latency_counts(-MaxLatency)  MinLatency: $latency_counts(-MinLatency)"
                
                ##统计计算测试值 ######################
                if {$location == [lindex $PORT_LIST 0 0] } {
                    set t3_3_counts_rx_a2b $rx_counts(-SigFrameCount)
                } elseif {$location == [lindex $PORT_LIST 1 0]} {
                    set t3_3_counts_tx_a $tx_counts(-GeneratorFrameCount)
                } elseif {$location == [lindex $PORT_LIST 2 0]} {
                    set t3_3_counts_rx_a2c $rx_counts(-SigFrameCount)
                }
                ################################  
            }
            # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count"
            # array set result_view [stc::get $latency_result_view_list]
            # puts [stc::get $latency_result_view_list]
            # parray result_view
            # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count, Average latency: $result_view(-AvgLatency)"

            # set rx_result_list [create_rx_statistic_handler $port_object_list]
            # set tx_result_list [create_tx_statistic_handler $port_object_list]
            # set latency_result_view_list [config_avg_latency_result_view $port_object_list]
            clear_all_results $port_object_list
        }        
    }
    ###打印输出  “MAC地址绑定”
	#puts "#####$TestIndex,0001,{t3_3_counts_tx_a:\"$t3_3_counts_tx_a\", t3_3_counts_rx_a2b:\"$t3_3_counts_rx_a2b\", t3_3_counts_rx_a2c:\"$t3_3_counts_rx_a2c\", t3_3_mac_capacity:\"$t3_3_mac_capacity\", t3_3_result:\"$t3_3_result\"}"

    release_env
}

main

