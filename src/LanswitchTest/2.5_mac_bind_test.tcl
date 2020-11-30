#NO PARAMETER
source pkgIndex.tcl
package require StcLib
package require SpirentTestCenter


#光口: EthernetFiber, 电口：EthernetCopper
#端口速率:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
# set PORT_LIST {
    # { //192.168.0.100/3/1 EthernetFiber SPEED_1G } 
	# { //192.168.0.100/3/2 EthernetFiber SPEED_1G } 
# }
set PORT_LIST [lrange $configStr 0 1]
#测试时长
set DURATION 30
#绑定的静态mac
set STATIC_MAC 00:00:01:00:00:01


#交换机配置相关脚本***********************************************************#
#被测交换机所对应的配置模板
set SwitchTemp PSW-618GB
#选择的配置串口
set ComPort	COM5	
#是否配置交换机
set SwitchConfigEnable 0 

global remark
#测试项序号，固定值
set remark 0003
if {$SwitchConfigEnable} {
	#测试项标号,固定值			
	set TestItem 2.5
	#调用串口收发脚本，对交换机进行配置，并返回配置结果
	set result [exec python SwitchConfig.py $SwitchTemp $ComPort $TestItem]
	puts $result
    if {result} {
        puts "@@@@@$remark, 交换机配置成功"
    } else {
        puts "@@@@@$remark, 交换机配置失败"
    }
}
#*****************************************************************************#


#mac地址绑定测试
#proc main { } {
    global PORT_LIST
    global DURATION
    #global STATIC_MAC
    global remark
    
    #输出运行状态信息
	puts "@@@@@$remark, 初始化设置"
    
    set stream_name(1) "Stream(OK)"
    set stream_name(2) "Stream(NOK)"

    set port_object_list [init_env $PORT_LIST]
    lappend tx_port_list [lindex $port_object_list 0]

    set stream_block_list [init_2_5_stream [lindex $port_object_list 0] $STATIC_MAC]

    set generator_list [init_generator_with_duration $tx_port_list $DURATION 100 "START_OF_FRAME"]
    set analyzer_list [init_analyzer $port_object_list]
    config_result_view_mode JITTER
    
    puts "Test mac bind with duration $DURATION"
    #输出运行状态信息
	puts "@@@@@$remark, 开始测试"
    
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
        
        ##统计计算测试值 ######################
		if {$index == 1} {
			if {$tx_counts(-FrameCount) == $jitter_counts(-FrameCount)} {
				set t2_5_normal_value 1
			} else {set t2_5_normal_value 0}
		} elseif {$index == 2} {
			if {$jitter_counts(-FrameCount) == 0} {
				set t2_5_mac_bind_value 1
			} else {set t2_5_mac_bind_value 0}
        }
        ################################
        
        set index [expr $index+1]
    }
    
    #输出运行状态信息
	puts "@@@@@$remark, 测试完成"
	#输出结论信息
	if {$t2_5_normal_value == 1 && $t2_5_mac_bind_value == 1} {
		set t2_5_result 1
		puts "@@@@@$remark, 通过"
	} else {
		set t2_5_result 0
		puts "@@@@@$remark, 失败"
	}
	
    
    stc::perform analyzerStop -analyzerList $analyzer_list
    # array set result_view [stc::get $jitter_result_view]
    # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count, Average jitter: $result_view(-AvgJitter), Max jitter: $result_view(-MaxJitter), Min jitter: $result_view(-MinJitter)"
    clear_all_results $port_object_list  

    release_env
    puts "@@@@@$remark, 生成报表中，请稍等……"
    stc::sleep 8
    ###打印输出  “MAC地址绑定”
	puts "#####$remark,0001,{t2_5_mac_bind_value:\"$t2_5_mac_bind_value\", t2_5_result:\"$t2_5_result\"}"
# }

# main


