source pkgIndex.tcl
package require StcLib
package require SpirentTestCenter

#������־��-logTo ����־����·�� ��ʹ��stdoutΪ��׼�����  -loglevel �� ��ѡ DEBUG�� INFO ��WARN �� ERROR ���֣�
stc::config automationoptions -logTo "aTemplateLog.txt" -logLevel DEBUG


	# puts $configStr
	# puts $ComPort
	# puts $DURATION
	# puts $FRAME_LIST
	# puts $LOAD_LIST
	# puts $REPEAT_TIME


#���: EthernetFiber, ��ڣ�EthernetCopper
#�˿�����:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
# set PORT_LIST {
    # { //192.168.0.100/3/1 EthernetFiber SPEED_1G } 
	# { //192.168.0.100/3/2 EthernetFiber SPEED_1G } 
	# { //192.168.0.100/3/3 EthernetFiber SPEED_1G } 
# }
set PORT_LIST [lrange $configStr 0 2]

#����ʱ��
set DURATION 30

#������������ؽű�***********************************************************#
#���⽻��������Ӧ������ģ��
set SwitchTemp PSW-618GB
#ѡ������ô���
#set ComPort	COM5	
#�Ƿ����ý�����
set SwitchConfigEnable 0 

#��������ţ��̶�ֵ
#global remark 
if {$SwitchConfigEnable} {
	#��������,�̶�ֵ			
	set TestItem 2.1
	#���ô����շ��ű����Խ������������ã����������ý��
	set result [exec python SwitchConfig.py $SwitchTemp $ComPort $TestItem $remark]
	puts $result
    if {$result} {
        puts "&&&&&$remark, ���������óɹ�"
    } else {
        puts "&&&&&$remark, ����������ʧ��"
    }    
}
#*****************************************************************************#

#����֡���˲��ԣ���������֡��FCS����֡������֡������֡
#proc main { } {
    global PORT_LIST
    global DURATION
    global remark
    #global sock

	#�������״̬��Ϣ
	puts "@@@@@$remark, ��ʼ������"
    #puts $sock  "@@@@@$remark, ��ʼ������"  
    #flush $sock 

    set stream_name(1) "Stream(OK)"
    set stream_name(2) "Stream(FCS)"
    set stream_name(3) "Stream(Long)"
    set stream_name(4) "Stream(Short)"

    set port_object_list [init_env $PORT_LIST]
    lappend tx_port_list [lindex $port_object_list 0]

    set stream_block_list [init_2_1_stream [lindex $port_object_list 0]]

    set generator_list [init_generator_with_duration $tx_port_list $DURATION 100 "START_OF_FRAME"]
    set analyzer_list [init_analyzer $port_object_list]
    config_result_view_mode JITTER
    
    puts "Test frame filter with duration $DURATION"
	#�������״̬��Ϣ
	puts "@@@@@$remark, ��ʼ����"

    set rx_result_list [create_rx_statistic_handler $port_object_list]
    set tx_result_list [create_tx_statistic_handler $port_object_list]

    set jitter_result_view_list [config_jitter_result_view $stream_block_list]
    set tx_stream_results [config_tx_stream_result_view $stream_block_list]
    stc::sleep 3
    # ����analyzer��generator
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
        puts "$stream_name($index) : TxPort: [lindex [lindex $PORT_LIST 0] 0], RxPort: $jitter_counts(-RxPort), Send frame: $tx_counts(-FrameCount), Receive frame:  $jitter_counts(-FrameCount), Dropped frame:  $jitter_counts(-DroppedFrameCount), Dropped Percentage: $jitter_counts(-DroppedFramePercent)"
        
		##ͳ�Ƽ������ֵ ######################
		if {$index == 1} {
			if {$tx_counts(-FrameCount) != $jitter_counts(-FrameCount)} {
				#���ش��󣬲��˳��ű�
				set t2_1_normal_value 0
			} else {set t2_1_normal_value 1}
		} elseif {$index == 2} {
			if {$jitter_counts(-FrameCount) == 0} {
				set t2_1_fcs_value 1
			} else {set t2_1_fcs_value 0}
		} elseif {$index == 3} {
			if {$jitter_counts(-FrameCount) == 0} {
				set t2_1_long_value 1
			} else {set t2_1_long_value 0}
		} elseif {$index == 4} {
			if {$jitter_counts(-FrameCount) == 0} {
				set t2_1_short_value 1
			} else {set t2_1_short_value 0}
		}
		################################
		
		set index [expr $index+1]
    }
	
    foreach var1 $rx_result_list var2 $tx_result_list var3 $port_object_list {
        array set rx_counts [stc::get $var1]
        array set tx_counts [stc::get $var2]
        set location [stc::get $var3 -location]
        # parray rx_counts
        # parray tx_counts
        puts "Port: $location  Send frame:  $tx_counts(-GeneratorFrameCount), Receive sig frame:  $rx_counts(-SigFrameCount), Recive total frame: $rx_counts(-TotalFrameCount)"
	}
	#�������״̬��Ϣ
	puts "@@@@@$remark, �������"
	#���������Ϣ
	if {$t2_1_fcs_value == 1 && $t2_1_long_value == 1 && $t2_1_short_value == 1} {
		set t2_1_result 1
		puts "@@@@@$remark, ͨ��"
	} else {
		set t2_1_result 0
		puts "@@@@@$remark, ʧ��"
	}
	
	
    stc::perform analyzerStop -analyzerList $analyzer_list
    # array set result_view [stc::get $jitter_result_view]
    # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count, Average jitter: $result_view(-AvgJitter), Max jitter: $result_view(-MaxJitter), Min jitter: $result_view(-MinJitter)"
    clear_all_results $port_object_list  

    release_env
    stc::sleep 8
    ###��ӡ���   ������֡���ˡ�
	puts "#####$remark,0001,{t2_1_fcs_value:\"$t2_1_fcs_value\", t2_1_short_value:\"$t2_1_short_value\", t2_1_long_value:\"$t2_1_long_value\", t2_1_result:\"$t2_1_result\"}"
    
    
#}

#main

