# 3.7 ������֡
source pkgIndex.tcl

package require StcLib
package require SpirentTestCenter


#���: EthernetFiber, ��ڣ�EthernetCopper
#�˿�����:   SPEED_10M, SPEED_100M, SPEED_1G, SPEED_10G, SPEED_40G, SPEED_100G
set PORT_LIST {
    { //192.168.0.100/3/1 EthernetFiber SPEED_1G } 
    { //192.168.0.100/3/2 EthernetFiber SPEED_1G } 
}

#֡���б�
set FRAME_LEN_LIST {64 65 256 512 1024 1280 1518}

#����ʱ��
set DURATION 2

#�ظ�����
set REPEAT_TIME 2

#��������ţ��̶�ֵ
set TestIndex T3.7

set t3_7_result 1
set ValueList "#####$TestIndex,0001, {"
set PORT_LIST_COUNT [llength $PORT_LIST]

proc split_port_list {port_list} {
    set 100M_port_list {}
    set 1G_port_list {}
    foreach var $port_list {
        if {[lindex $var 2] == "SPEED_1G" } {
            lappend 1G_port_list $var
        } elseif {[lindex $var 2] == "SPEED_100M"} {
            lappend 100M_port_list $var
        }
    }

    if { [expr [llength $1G_port_list] % 2] != 0 || [expr [llength $1G_port_list] % 2] } {
        puts "Should select correct number of ports"
        exit 1
    }

    lappend splited_port_list $100M_port_list
    lappend splited_port_list $1G_port_list
    return $splited_port_list
}


proc main { } {
    global PORT_LIST
    global DURATION
    global FRAME_LEN_LIST
    global REPEAT_TIME
    global TestIndex
    global t3_7_result
    global ValueList
    global PORT_LIST_COUNT
    
    #�������״̬��Ϣ
    puts "@@@@@$TestIndex, ��ʼ������"

    set splited_ports [split_port_list $PORT_LIST]
    set 100m_ports [lindex $splited_ports 0]
    set 1g_ports [lindex $splited_ports 1]

    if {[llength $100m_ports] != 0} {
        set port_object_list1 [init_env $100m_ports]
        set stream_block_list1 [init_fullmesh_stream $port_object_list1]
        set generator_list1 [init_generator_with_duration $port_object_list1 $DURATION 100]
        set analyzer_list1 [init_analyzer $port_object_list1]
    }
    if {[llength $1g_ports] != 0} {
        set port_object_list2 [init_env $1g_ports]
        set stream_block_list2 [init_fullmesh_stream $port_object_list2]
        set generator_list2 [init_generator_with_duration $port_object_list2 $DURATION 100]
        set analyzer_list2 [init_analyzer $port_object_list2]
    }

    # learning
    if {[llength $100m_ports] != 0} {
        start_generator_list $generator_list1
    }
    if {[llength $1g_ports] != 0} {
        start_generator_list $generator_list2
    }
    stc::sleep 5
    if {[llength $100m_ports] != 0} {
        stc::perform generatorStop -generatorList $generator_list1
        stc::perform analyzerStop -analyzerList $analyzer_list1
    }
    if {[llength $1g_ports] != 0} {
        stc::perform generatorStop -generatorList $generator_list2
        stc::perform analyzerStop -analyzerList $analyzer_list2
    }   
    stc::sleep 2
    if {[llength $100m_ports] != 0} {
        clear_all_results $port_object_list1
    }
    if {[llength $1g_ports] != 0} {
        clear_all_results $port_object_list2
    }

    #�������״̬��Ϣ
    puts "@@@@@$TestIndex, ��ʼ����"
    
    #��ʼ����
    foreach frame_length  $FRAME_LEN_LIST {
        puts "Test back to back with frame length $frame_length, duration $DURATION"
        puts "@@@@@$TestIndex, ����֡�� $frame_length �ֽ�, ����ʱ�� $DURATION ��"
        
        if {[llength $100m_ports] != 0} {
            set rx_result_list1 [create_rx_statistic_handler $port_object_list1]
            set tx_result_list1 [create_tx_statistic_handler $port_object_list1]
        }
        if {[llength $1g_ports] != 0} {
            set rx_result_list2 [create_rx_statistic_handler $port_object_list2]
            set tx_result_list2 [create_tx_statistic_handler $port_object_list2]
        }
        stc::sleep 3
        # ���ð����͸���
        if {[llength $100m_ports] != 0} {
            init_generator_with_duration $port_object_list1 $DURATION 100
            config_stream_length_and_load $stream_block_list1 $frame_length 100
        }
        if {[llength $1g_ports] != 0} {
            init_generator_with_duration $port_object_list2 $DURATION 100
            config_stream_length_and_load $stream_block_list2 $frame_length 100
        }

        # ����analyzer��generator
        if {[llength $100m_ports] != 0} {
            start_analyzer_list $analyzer_list1
        }
        if {[llength $1g_ports] != 0} {
            start_analyzer_list $analyzer_list2
        }
        stc::sleep 3
        for {set index 0} {$index < $REPEAT_TIME} {incr index} {
            puts "Start round [expr $index+1]"
            if {[llength $100m_ports] != 0} {
                start_generator_list $generator_list1
            }
            if {[llength $1g_ports] != 0} {
                start_generator_list $generator_list2
            }
            # stc::sleep 2
            stc::sleep $DURATION
            stc::sleep 5
            if {[llength $100m_ports] != 0} {
                stc::perform generatorStop -generatorList $generator_list1
            }
            if {[llength $1g_ports] != 0} {
                stc::perform generatorStop -generatorList $generator_list2
            }   
            stc::sleep 2
        }

        set tx_frame_count 0
        set rx_frame_count 0

        if {[llength $100m_ports] != 0} {
            foreach var1 $rx_result_list1 var2 $tx_result_list1 var3 $port_object_list1 {
                array set rx_counts [stc::get $var1]
                array set tx_counts [stc::get $var2]
                set tx_frame_count [expr $tx_frame_count + $tx_counts(-GeneratorFrameCount)]
                set rx_frame_count [expr $rx_frame_count + $rx_counts(-SigFrameCount)]
                set location [stc::get $var3 -location]
                # parray rx_counts
                # parray tx_counts
                puts "Port: $location  Send frame:  $tx_counts(-GeneratorFrameCount), Receive sig frame:  $rx_counts(-SigFrameCount), Recive total frame: $rx_counts(-TotalFrameCount)"
            }
        }
        if {[llength $1g_ports] != 0} {
            foreach var1 $rx_result_list2 var2 $tx_result_list2 var3 $port_object_list2 {
                array set rx_counts [stc::get $var1]
                array set tx_counts [stc::get $var2]
                set tx_frame_count [expr $tx_frame_count + $tx_counts(-GeneratorFrameCount)]
                set rx_frame_count [expr $rx_frame_count + $rx_counts(-SigFrameCount)]
                set location [stc::get $var3 -location]
                # parray rx_counts
                # parray tx_counts
                puts "Port: $location  Send frame:  $tx_counts(-GeneratorFrameCount), Receive sig frame:  $rx_counts(-SigFrameCount), Recive total frame: $rx_counts(-TotalFrameCount)"
            }
        }
        puts "Total Send frame: $tx_frame_count, Total Receive frame: $rx_frame_count"
        ##ͳ�Ƽ������ֵ ######################
        set tValue [expr 100*(double($tx_frame_count - $rx_frame_count)/$tx_frame_count)]
        append ValueList "t_3_7_lost_value_$frame_length:\"$tValue\","
        #puts $ValueList

        if {$rx_frame_count != $tx_frame_count} {
            set t3_7_result 0
            puts "@@@@@$TestIndex, ֡�� $frame_length �ֽڲ�����ɡ�ʧ��"
        } else {
            puts "@@@@@$TestIndex, ֡�� $frame_length �ֽڲ�����ɡ�ͨ��"
        }        
        ################################
        

        if {[llength $100m_ports] != 0} {
            stc::perform analyzerStop -analyzerList $analyzer_list1
        }
        if {[llength $1g_ports] != 0} {
            stc::perform analyzerStop -analyzerList $analyzer_list2
        }

        if {[llength $100m_ports] != 0} {
            clear_all_results $port_object_list1
        }
        if {[llength $1g_ports] != 0} {
            clear_all_results $port_object_list2
        }               
    }
    
    #�������״̬��Ϣ
    puts "@@@@@$TestIndex, �������"
    
    #���������Ϣ
    if {$t3_7_result} {
        puts "@@@@@$TestIndex, ͨ��"
    } else {
        puts "@@@@@$TestIndex, ʧ��"
    }
    append ValueList "t3_7_result:\"$t3_7_result\"\}"
    puts $ValueList
    
    release_env
}

main

