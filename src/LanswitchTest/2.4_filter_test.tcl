#NO PARAMETER
source pkgIndex.tcl
package require StcLib
package require SpirentTestCenter


#���: EthernetFiber, ��ڣ�EthernetCopper
#�˿�����:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
# set PORT_LIST {
    # { //192.168.0.100/3/1 EthernetFiber SPEED_1G } 
	# { //192.168.0.100/3/2 EthernetFiber SPEED_1G } 
	# { //192.168.0.100/3/3 EthernetFiber SPEED_1G } 
    # { //192.168.0.100/3/4 EthernetFiber SPEED_1G } 
# }

set PORT_LIST [lrange $configStr 0 4]

#����ʱ��
set DURATION 30


#������������ؽű�***********************************************************#
#���⽻��������Ӧ������ģ��
set SwitchTemp PSW-618GB
#ѡ������ô���
set ComPort	COM5	
#�Ƿ����ý�����
set SwitchConfigEnable 0 

#��������ţ��̶�ֵ
global remark
#set remark 0002
if {$SwitchConfigEnable} {
	#��������,�̶�ֵ			
	set TestItem 2.4
	#���ô����շ��ű����Խ������������ã����������ý��
	set result [exec python SwitchConfig.py $SwitchTemp $ComPort $TestItem]
	puts $result
    if {result} {
        puts "&&&&&$remark, ���������óɹ�"
    } else {
        puts "&&&&&$remark, ����������ʧ��"
    }
}
#*****************************************************************************#


#����֡���˲��ԣ�����Դmac����֡��FCS����֡��mac��ַ��ͻ֡������֡
#proc main { } {
    global PORT_LIST
    global DURATION
    global remark

	#�������״̬��Ϣ
	puts "@@@@@$remark, ��ʼ������"

    set stream_name(1) "src error"
    set stream_name(2) "fcs error"
    set stream_name(3) "src mac conflict 1"
    set stream_name(4) "src mac conflict 2"
    set stream_name(5) "normal 1"
    set stream_name(6) "normal 2"

    set port_object_list [init_env $PORT_LIST]

    set stream_block_list [init_2_4_stream $port_object_list]

    set generator_list [init_generator_with_duration $port_object_list 1 10 "START_OF_FRAME"]
    lappend learn_generator_list [lindex $generator_list 2]
    lappend learn_generator_list [lindex $generator_list 3]

    # learning
    start_generator_list $learn_generator_list
    stc::sleep 10
    stc::perform generatorStop -generatorList $learn_generator_list
    clear_all_results $port_object_list
    stc::sleep 2
    stc::apply   

    
	#�������״̬��Ϣ
	puts "@@@@@$remark, ��ʼ����"
	
    puts "Test filter with duration $DURATION"
    set analyzer_list [init_analyzer $port_object_list]
    config_result_view_mode JITTER
    set generator_list [init_generator_with_duration $port_object_list $DURATION 10 "START_OF_FRAME"]
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
        if {$index <= 3} {
            puts "$stream_name($index): TxPort: [lindex [lindex $PORT_LIST 0] 0], RxPort: $jitter_counts(-RxPort),  Send frame: $tx_counts(-FrameCount), Receive frame:  $jitter_counts(-FrameCount)"
        } elseif {$index == 4} {
            puts "$stream_name($index): TxPort: [lindex [lindex $PORT_LIST 1] 0], RxPort: $jitter_counts(-RxPort),  Send frame: $tx_counts(-FrameCount), Receive frame:  $jitter_counts(-FrameCount)"
        } elseif {$index == 5} {
            puts "$stream_name($index): TxPort: [lindex [lindex $PORT_LIST 2] 0], RxPort: $jitter_counts(-RxPort),  Send frame: $tx_counts(-FrameCount), Receive frame:  $jitter_counts(-FrameCount)"
        } elseif {$index == 6} {
            puts "$stream_name($index): TxPort: [lindex [lindex $PORT_LIST 3] 0], RxPort: $jitter_counts(-RxPort),  Send frame: $tx_counts(-FrameCount), Receive frame:  $jitter_counts(-FrameCount)"
        }
        
		##ͳ�Ƽ������ֵ ######################
		if {$index == 1} {
			if {$jitter_counts(-FrameCount) == 0} {
				set t2_4_src_error_value 1
			} else {set t2_4_src_error_value 0}
		} elseif {$index == 2} {
			if {$jitter_counts(-FrameCount) == 0} {
				set t2_4_fcs_error_value 1
			} else {set t2_4_fcs_error_value 0}
		} elseif {$index == 5} {
			if {$jitter_counts(-FrameCount) == $tx_counts(-FrameCount)} {
				set temp 1
			} else {set temp 0}
		} elseif {$index == 6} {
			if {$jitter_counts(-FrameCount) == $tx_counts(-FrameCount) && $temp == 1} {
				set t2_4_src_mac_conflict_value 1
			} else {set t2_4_src_mac_conflict_value 0}
		}
		################################
		
		set index [expr $index+1]
    }
    
    #�������״̬��Ϣ
	puts "@@@@@$remark, �������"
	#���������Ϣ
	if {$t2_4_src_error_value == 1 && $t2_4_fcs_error_value == 1 && $t2_4_src_mac_conflict_value} {
		set t2_4_result 1
		puts "@@@@@$remark, ͨ��"
	} else {
		set t2_4_result 0
		puts "@@@@@$remark, ʧ��"
	}
	

    stc::perform analyzerStop -analyzerList $analyzer_list
    # array set result_view [stc::get $jitter_result_view]
    # puts "Send frame: $tx_frame_count, Receive frame: $rx_frame_count, Average jitter: $result_view(-AvgJitter), Max jitter: $result_view(-MaxJitter), Min jitter: $result_view(-MinJitter)"
    clear_all_results $port_object_list  

    release_env
    
    puts "@@@@@$remark, ���ɱ����У����Եȡ���"
    stc::sleep 8
    ###��ӡ���  �����˹��ܡ�
	puts "#####$remark,0001,{t2_4_src_error_value:\"$t2_4_src_error_value\", t2_4_fcs_error_value:\"$t2_4_fcs_error_value\", t2_4_src_mac_conflict_value:\"$t2_4_src_mac_conflict_value\", t2_4_result:\"$t2_4_result\"}"
# }


# main



