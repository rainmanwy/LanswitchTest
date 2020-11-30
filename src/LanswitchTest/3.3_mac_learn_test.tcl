source pkgIndex.tcl

package require StcLib
package require SpirentTestCenter


#光口: EthernetFiber, 电口：EthernetCopper
#端口速率:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
set PORT_LIST {
    { //192.168.0.100/3/1 EthernetFiber SPEED_1G } 
	{ //192.168.0.100/3/2 EthernetFiber SPEED_1G } 
    { //192.168.0.100/3/3 EthernetFiber SPEED_1G } 
}

# mac容量
set MAC_CAPACITY 8000

# 学习速率(负载)
set SPEED 2000

#测试时长
set DURATION 10

#测试项序号，固定值
set TestIndex T3_3

set t3_3_result 1
set ValueList "#####$TestIndex,0001, {"

#静态组播测试
proc main { } {
    global PORT_LIST
    global DURATION
    global MAC_CAPACITY
    global SPEED
    global TestIndex
    global t3_3_result

    
    #输出运行状态信息
    puts "@@@@@$TestIndex, 初始化设置"

    set port_object_list [init_env $PORT_LIST]
    lappend learn_port_list [lindex $port_object_list 0]
    lappend tx_port_list [lindex $port_object_list 1]

    # mac学习
    init_3_3_learn_stream [lindex $port_object_list 0] $MAC_CAPACITY
    set learn_generator_list [ init_generator_with_burst $learn_port_list $MAC_CAPACITY $SPEED ]
    start_generator_list $learn_generator_list
    stc::sleep 5
    stc::perform generatorStop -generatorList $learn_generator_list
    # stc::perform analyzerStop -analyzerList $analyzer_list
    clear_all_results $port_object_list
    stc::sleep 2
    stc::apply   

    #输出运行状态信息
    puts "@@@@@$TestIndex, 开始测试"
    
    # 测试mac
    puts "Test MAC learn with capacity: $MAC_CAPACITY, speed: $SPEED"
    puts "@@@@@$TestIndex, 测试地址容量: $MAC_CAPACITY, 地址学习速率: $SPEED"
    set stream_block_list [init_3_3_test_stream [lindex $port_object_list 1] [lindex $port_object_list 0] $MAC_CAPACITY]

    set generator_list [init_generator_with_burst $tx_port_list $MAC_CAPACITY $SPEED]
    set analyzer_list [init_analyzer $port_object_list]
    # config_result_view_mode JITTER
    set rx_result_list [create_rx_statistic_handler $port_object_list]
    set tx_result_list [create_tx_statistic_handler $port_object_list]

    # set jitter_result_view_list [config_jitter_result_view $stream_block_list]
    # set tx_stream_results [config_tx_stream_result_view $stream_block_list]
    stc::sleep 3
    # 运行analyzer和generator
    start_analyzer_list $analyzer_list
    stc::sleep 3
    start_generator_list $generator_list
    stc::sleep $DURATION
    stc::perform generatorStop -generatorList $generator_list
    stc::sleep 3
    # refresh_result_view $jitter_result_view_list 2

    # set index 1
    # foreach var1 $jitter_result_view_list var2 $tx_stream_results {
    #     set jitter [stc::get $var1  -resultHandleList]
    #     set tx_result [stc::get $var2  -resultHandleList]
    #     array set jitter_counts [stc::get $jitter]
    #     array set tx_counts [stc::get $tx_result]
    #     # parray jitter_counts
    #     puts "Result: TxPort: [lindex [lindex $PORT_LIST 0] 0], RxPort: $jitter_counts(-RxPort),  Send frame: $tx_counts(-FrameCount), Receive frame:  $jitter_counts(-FrameCount)"
    #     set index [expr $index+1]
    # }
    foreach var1 $rx_result_list var2 $tx_result_list var3 $port_object_list {
        array set rx_counts [stc::get $var1]
        array set tx_counts [stc::get $var2]
        # set tx_frame_count [expr $tx_frame_count + $tx_counts(-GeneratorFrameCount)]
        # set rx_frame_count [expr $rx_frame_count + $rx_counts(-TotalFrameCount)]
        set location [stc::get $var3 -location]
        puts "Port: $location  Send frame:  $tx_counts(-GeneratorFrameCount), Receive frame:  $rx_counts(-SigFrameCount)"

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

    #输出运行状态信息
    puts "@@@@@$TestIndex, 测试完成"
    
    #输出结论信息
    set t3_3_mac_capacity [expr $t3_3_counts_tx_a - $t3_3_counts_rx_a2c]
    if {$t3_3_mac_capacity >= 4096} {
        set t3_3_result 1
        puts "@@@@@$TestIndex, 通过"
    } else {
        set t3_3_result 0
        puts "@@@@@$TestIndex, 失败"
    }
    
    ###打印输出  “MAC地址绑定”
	puts "#####$TestIndex,0001,{t3_3_counts_tx_a:\"$t3_3_counts_tx_a\", t3_3_counts_rx_a2b:\"$t3_3_counts_rx_a2b\", t3_3_counts_rx_a2c:\"$t3_3_counts_rx_a2c\", t3_3_mac_capacity:\"$t3_3_mac_capacity\", t3_3_result:\"$t3_3_result\"}"

    stc::perform analyzerStop -analyzerList $analyzer_list
    # array set result_view [stc::get $jitter_result_view]
    # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count, Average jitter: $result_view(-AvgJitter), Max jitter: $result_view(-MaxJitter), Min jitter: $result_view(-MinJitter)"
    clear_all_results $port_object_list  

    release_env
}

main

