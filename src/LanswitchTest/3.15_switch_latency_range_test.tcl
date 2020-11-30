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

#帧长列表
set FRAME_LEN_LIST {64 128}

#测试时长
set DURATION 10


proc main { } {
    global PORT_LIST
    global DURATION
    global FRAME_LEN_LIST

    set StreamConfig(64) {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:04:00:05</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_2162" pdu="custom:Custom"><pattern>4003003000FFFFFE608167800101A2816130815E800430303030820208598304000000018501018781480000000000000000</pattern></pdu></pdus></config></frame>}
    set StreamConfig(128) {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:04:00:05</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_3358" pdu="custom:Custom"><pattern>4003007000FFFFFE608167800101A2816130815E80043030303082020859830400000001850101878148000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000</pattern></pdu></pdus></config></frame>}
    set StreamConfig(256) {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:04:00:05</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_3383" pdu="custom:Custom"><pattern>400300F000FFFFFE6081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000</pattern></pdu></pdus></config></frame>}
    set StreamConfig(512) {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:04:00:05</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_3406" pdu="custom:Custom"><pattern>400301F000FFFFFE6081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000</pattern></pdu></pdus></config></frame>}
    set StreamConfig(1024) {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:04:00:05</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_3428" pdu="custom:Custom"><pattern>400303F000FFFFFE6081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000</pattern></pdu></pdus></config></frame>}
    set StreamConfig(1280) {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:04:00:05</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_3449" pdu="custom:Custom"><pattern>400304EC000FFFFFE6081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000</pattern></pdu></pdus></config></frame>}
    set StreamConfig(1514) {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:04:00:05</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_3470" pdu="custom:Custom"><pattern>400305DC00FFFFFE6081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010CCD04000500C00000420388BA40030030000000006081E7800101A281E13081DE800430303030820208598304000000018501018781C8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000</pattern></pdu><pdu name="custom_3471" pdu="custom:Custom"></pdu></pdus></config></frame>}

    set port_object_list [init_env $PORT_LIST]

    lappend sv_port_list [lindex $port_object_list 0]
    lappend background_port_list [lindex $port_object_list 2]
    lappend background_port_list [lindex $port_object_list 3]
    lappend background_port_list [lindex $port_object_list 4]
    lappend learn_port_list [lindex $port_object_list 1]

    set stream_block_list [init_3_13_stream $port_object_list]
    set learn_stream_list [init_single_stream [lindex $port_object_list 1] [lindex $port_object_list 0]]


    set tx_generator_list [init_generator_for_3_13 $port_object_list $DURATION]
    set learn_generator_list [init_generator_with_duration $port_object_list 1 10 "START_OF_FRAME"]
    set analyzer_list [init_analyzer $port_object_list]
    config_result_view_mode  HISTOGRAM

    # 学习
    start_generator_list $learn_generator_list
    stc::sleep 5
    stc::perform generatorStop -generatorList $learn_generator_list
    stc::perform analyzerStop -analyzerList $analyzer_list
    clear_all_results $port_object_list

    set tx_generator_list [init_generator_for_3_13 $port_object_list $DURATION]
    # 测试
    foreach frame_length  $FRAME_LEN_LIST {
        puts "Test switch latency range with frame length $frame_length, duration $DURATION"
        config_3_13_stream [lindex $stream_block_list 0] $StreamConfig($frame_length)

        set rx_result_list [create_rx_statistic_handler $port_object_list]
        set tx_result_list [create_tx_statistic_handler $port_object_list]
        set latency_result_view_list [config_avg_latency_result_view $port_object_list]
        stc::sleep 3
        # 配置包长和负载
        # init_generator_with_duration $port_object_list $DURATION $load "END_OF_FRAME"
        # config_stream_length_and_load $stream_block_list $frame_length
        # 运行analyzer和generator
        set filter [format {<frame ><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>%s</dstMac></pdu></pdus></config></frame>} 01:0c:cd:04:00:05 ]
        set capture [start_rx_capture [lindex $port_object_list 1] $filter 01:0c:cd:04:00:05]

        start_analyzer_list $analyzer_list
        stc::sleep 3
        start_generator_list $tx_generator_list
        stc::sleep 2
        stc::sleep $DURATION
        stc::sleep 2
        stc::perform generatorStop -generatorList $tx_generator_list
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
        }
        stop_capture $capture [format "3_15_%s.pcap" $frame_length]
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
    release_env
}

main

