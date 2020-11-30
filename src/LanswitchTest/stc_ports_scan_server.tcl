#exec taskkill /f /im tclsh.exe
#exec netstat -aon|findstr ":1082"

puts "Load package success!"

#set ChassisIP 192.168.0.100
array set c_arr "" 
array set sock_arr "" 
set SERVER_IP 127.0.0.1 
#set SERVER_PORT [lindex $argv 0] 
set SERVER_PORT 1082 

set scanPortLoop 0
set tempPortsList {}

set CHASSISSCANCMD "#####CONNECTCHASSIS"
set PORTSCANCMD "#####CONNECT"
set PORTSCANENDCMD "#####005"
set ENDSCRIPT "#####END"
set TESTCMD "#####TESTTASK"
set CHASSISREPLY "#####getSpirentCard"


set CHASSISSCANCMDECHO "CONNECTCHASSIS"
set PORTSCANCMDECHO "CONNECT"
set PORTSCANENDCMDECHO "005"
set ENDSCRIPTECHO "END"
set TESTCMDECHO "TESTTASK"
set CHASSISECHO "getSpirentCard"


# set TestList [dict create t0001 "2.1_frame_filter_test.tcl" t0002 "2.4_filter_test.tcl" t0003 "2.5_mac_bind_test.tcl" t0004 "2.11_broadcast_suppress_test.tcl" \
			# t0005 "2.12_vlan_tag_test.tcl" t0006 "2.13_vlan_trunk_test.tcl" t0007 "2.14_qos_test.tcl" t0008 "2.15_port_mirror_test.tcl" \
			# t0009 "3.1_throughput_test.tcl" t0010 "3.2_forward_speed_test.tcl" t0011 "3.3_mac_learn_test.tcl" t0012 "3.4_latency_test.tcl" \
			# t0013 "3.5_jitter_test.tcl" t0014 "3.6_frame_loss_test.tcl" t0015 "3.7_b2b_test.tcl" t0016 "3.8_HOL_blocking_test.tcl" \
			# t0017 "3.9_static_multicast_test.tcl" t0018 "3.11_multicast_flowcontrol_test.tcl" t0019 "3.13_switch_latency_test.tcl" \
			# t0020 "3.13_switch_latency_test.tcl" t0021 "3.14_switch_latency_cumu_test.tcl" t0022 "3.15_switch_latency_range_test.tcl" \
			# t0023 "3.16_OVF_test.tcl" t0024 "" t0025 "" t0026 ""]
            
set TestList {
                {t0001 "2.1_frame_filter_test.tcl"}
                {t0002 "2.4_filter_test.tcl"}
                {t0003 "2.5_mac_bind_test.tcl"}
                {t0004 "2.11_broadcast_suppress_test.tcl"}
                {t0005 "2.12_vlan_tag_test.tcl"}
                {t0006 "2.13_vlan_trunk_test.tcl"}
                {t0007 "2.14_qos_test.tcl"}
                {t0008 "2.15_port_mirror_test.tcl"}
                {t0009 "3.1_throughput_test.tcl"}
                {t0010 "3.2_forward_speed_test.tcl"}
                {t0011 "3.3_mac_learn_test.tcl"}
                {t0012 "3.4_latency_test.tcl"}
                {t0013 "3.5_jitter_test.tcl"}
                {t0014 "3.6_frame_loss_test.tcl"} 
                {t0015 "3.7_b2b_test.tcl"}
                {t0016 "3.8_HOL_blocking_test.tcl"}
                {t0017 "3.9_static_multicast_test.tcl"} 
                {t0018 "3.11_multicast_flowcontrol_test.tcl"} 
                {t0019 "3.13_switch_latency_test.tcl"}
                {t0020 "3.13_switch_latency_test.tcl"}
                {t0021 "3.14_switch_latency_cumu_test.tcl"} 
                {t0022 "3.15_switch_latency_range_test.tcl"}
                {t0023 "3.16_OVF_test.tcl"} 
                {t0024 ""} 
                {t0025 ""} 
                {t0026 ""}
            }

proc Scan_Data_Pro { readData} {
    
    global ChassisIP PORTSCANCMD portsList
    global MedialTypeList IDList LocationList ModelList StatusList PortIDList SlotList SpeedList TaskIDList SwitchIDList SwitchNameList SwitchPortList 
	#global tempPortsList
    #puts $readData
    #puts [expr [string length $PORTSCANCMD] + 2]
    
    set IDList          {}
    set LocationList    {}
    set ModelList       {}
    set StatusList      {}
    set PortIDList      {}
    set SlotList        {}
    set MedialTypeList  {}
    set SpeedList       {}
    set TaskIDList      {}
    set SwitchIDList    {}
    set SwitchNameList  {}
    set SwitchPortList  {}
    set portsList       {}   
    
    
    set x [string range $readData [expr [string length $PORTSCANCMD] + 2] end-1]
    #puts $x
    set x [string range $x 0 end-1]
    puts $x
    regsub -all \",\" $x " " x
    regsub -all \":\" $x " " x
    regsub -all \" $x "" x
    regsub -all \{ $x "" x
    regsub -all \} $x "" x
    puts $x
    set portInfoList [split $x ,]
    set portsInfoLenth [llength $portInfoList]
    puts $portInfoList
    set ChassisIP [lindex $portInfoList 0 3]
    foreach	portInfo $portInfoList {
        lappend IDList          [lindex $portInfo 1]
        lappend LocationList    [lindex $portInfo 3]
        lappend ModelList       [lindex $portInfo 5]
        lappend StatusList      [lindex $portInfo 7]
        lappend PortIDList      [lindex $portInfo 9]
        lappend SlotList        [lindex $portInfo 11]
        lappend MedialTypeList  [lindex $portInfo 13]
        lappend SpeedList       [lindex $portInfo 15]
        lappend TaskIDList      [lindex $portInfo 17]
        lappend SwitchIDList    [lindex $portInfo 19]        
		lappend SwitchNameList	[lindex $portInfo 21]
		lappend SwitchPortList  [lindex $portInfo 23]
        lappend portsList [format "//%s/%s/%s" $ChassisIP [lindex $portInfo 11] [lindex $portInfo 9]]
    }
    
     puts "***********************"
    
    
    
    puts "IDList         = $IDList        "
    puts "LocationList  = $LocationList"
    puts "ModelList     =$ModelList     "
    puts "StatusList    =$StatusList    "
    puts "PortIDList    =$PortIDList    "
    puts "SlotList      =$SlotList      "
    puts "MedialTypeList=$MedialTypeList"
    puts "SpeedList     =$SpeedList     "
    puts "TaskIDList    =$TaskIDList    "
    puts "SwitchIDList  =$SwitchIDList  "
    puts "SwitchNameList=$SwitchNameList"
    puts "SwitchPortList=$SwitchPortList"
    
    
    puts "***********************"
    puts $portsList
	
    return $portsList 
}

proc Test_Data_Pro { readData } {
	global TESTCMD
	global remark configStr ComPort DURATION FRAME_LIST LOAD_LIST REPEAT_TIME
	
	set remark [string range $readData 23 27]
	set x [string range $readData [string first SwitchTemp $readData] end-1]
	
	set v [string range $readData 43 [expr [string first SwitchTemp $readData]-5]]
	regsub -all \} $v "" v
    regsub -all AUTO $v SPEED_UNKNOWN v
	set configStr [split $v \{]

	regsub -all \"\" $x null x
    regsub -all :\" $x " " x
	regsub -all \", $x " " x
	regsub -all \" $x "" x   
	regsub -all : $x " " x 
	regsub -all , $x " " x 	
    puts $x
	
    #set configStr [regexp -inline -all {//(?:[0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}/[0-9]{1,2}} $readData]
    
	set ComPort 	[lindex $x 1]
	set DURATION 	[lindex $x 3]
	set FRAME_LIST 	[lindex $x 5]
	set LOAD_LIST 	[lindex $x 7]
	set REPEAT_TIME [lindex $x 9]
	
	puts "remark=$remark"
    puts "configStr=$configStr"
	puts "ComPort=$ComPort"
	puts "DURATION=$DURATION"
	puts "FRAME_LIST=$FRAME_LIST"
	puts "LOAD_LIST=$LOAD_LIST"
	puts "REPEAT_TIME=$REPEAT_TIME"
}
 
proc Create_Client { name } { 
	global c_arr SERVER_IP SERVER_PORT 
	set status [catch { socket $SERVER_IP $SERVER_PORT} res] 
	if {!$status } { 
		puts "Create client socket success. Client socket is $res" 
		set c_arr($name) $res 
		fconfigure $res -buffering line -blocking 0 
	} else { 
		error "Create clinet socket failed: $res" 
	} 
} 
 
proc Close_Client { name } { 
	global c_arr 
	if [info exists c_arr($name)] { 
		catch {close $c_arr($name)} res 
		unset c_arr($name) 
	} 
} 

;#******************************serial com **********************************************
proc ComSetup {ComPort ComRate} {
	set iChannel [open $ComPort w+]
	set rate $ComRate
	fconfigure $iChannel -mode $ComRate,n,8,1
	fconfigure $iChannel -blocking 0
	fconfigure $iChannel -buffering none
	fileevent $iChannel readable ""
	return $iChannel
}
proc GetData {iChannel} {
	global output
	update
	after 2000
	set cap [read -nonewline $iChannel]
	return "$cap"
}
proc SendCmd {channel command} {
	global output debug
	set letter_delay 10
	set commandlen [string length $command]
	for {set i 0} {$i < $commandlen} {incr i} {
		set letter [string index $command $i]
		after $letter_delay
		puts -nonewline $channel $letter
		if {$debug(dutConfig) == 1} {puts -nonewline $output "$letter"}
	}
	after $letter_delay
	puts -nonewline $channel "\n"
	if {$debug(dutConfig) == 1} {puts $output ""}
	after 500
	flush $channel
}
;#******************************serial com end **********************************************

proc Chassis_Scan { ChassisIP } {
    global CHASSISREPLY
    set szTemp "$CHASSISREPLY,\["
    #puts $szTemp
    #puts "connet to $ChassisIP"
	if {[catch {stc::connect $ChassisIP} msg]} {
        puts "连接 $ChassisIP 失败,请检查测试仪是否连接正常！"
		puts "MSG: $msg" 
        #stc::disconnect $ChassisIP
        stc::perform ChassisDisconnectAll 
        stc::perform ResetConfig -config system1 
        return
    }
	set chassisHandle [stc::get system1 -children-PhysicalChassisManager]
	#puts $chassisHandle
	set hChassis [stc::get $chassisHandle -children-PhysicalChassis]
    #puts $hChassis
    set chassisIpAddr [stc::get $hChassis -Hostname]
    #puts $chassisIpAddr
    set hTmList [stc::get $hChassis -children-PhysicalTestmodule]
    #puts $hTmList
    foreach hTm $hTmList {
        set tmProps [stc::get $hTm]
        #puts $tmProps
        set tmType [stc::get $hTm -PartNum]
        #puts $tmType
        set tmSlotIndex [stc::get $hTm -Index]
        set tmPortCount [stc::get $hTm -PortCount]
        #puts "qqqqq:$tmType $tmSlotIndex $tmPortCount"
        set hPgList [stc::get $hTm -children-PhysicalPortgroup]
        #puts hPgList
        foreach hPg $hPgList {
            set pgProps [stc::get $hPg]                
            set hPtList [stc::get $hPg -children-PhysicalPort]
            foreach hPt $hPtList {
                set ptPorts [stc::get $hPt]
                set ptPortsIndex [stc::get $hPt -Index]
                set pgLocation [format //%s/%s/%s $chassisIpAddr $tmSlotIndex $ptPortsIndex]
                #puts $pgLocation
                set pgLocationList [lappend $pgLocation]
                if {[stc::get $hPg -OwnershipState] != "OWNERSHIP_STATE_RESERVED"} {
                    set OwnerUser Available
                } else {
                    set OwnerUser [format %s@%s [stc::get $hPg -OwnerUserId] [stc::get $hPg -OwnerHostname]]
                    #puts $OwnerUser
                }
                append szTemp [format \{"location":"%s","model":"%s","status":"%s"\}, $pgLocation $tmType $OwnerUser]       
            }            
        }
    }
    
    set szResult [string range $szTemp 0 end-1]
    append szResult "]"
    #stc::perform chassisDisconnectAll
  
    return $szResult
    
}

proc Chassis_Scan_Loop { } {
    
}
;#----------------port scan------------------
proc Ports_Scan { portList } {
    global portNumList MedialTypeList
    set Project [stc::create project]
    list ptFaultList {}
    set portNumList {}
    puts $Project    
    puts $MedialTypeList
    foreach ptList $portList MedialType $MedialTypeList {
        set portNum [stc::create port -under $Project -location $ptList]
        #puts $portNum
        lappend portNumList $portNum
        #puts $portNumList
        stc::create $MedialType -under $portNum
    }
    stc::perform attachPorts -autoConnect true -portList $portNumList
    
    return $portNumList
}

proc Ports_Scan_Loop { portNumList } {
    global MedialTypeList IDList LocationList ModelList StatusList PortIDList SlotList SpeedList TaskIDList SwitchIDList SwitchPortList SwitchNameList portsList PORTSCANCMD
    set ptStatusT 1
    set szFault "$PORTSCANCMD,\["
    set ptStatusList [lindex [split [stc::perform PhyVerifyLinkUp -portList $portNumList] -] 7 1]
    puts $ptStatusList
    set ptFaultList [regexp -inline -all {//(?:[0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}/[0-9]{1,2}} $ptStatusList]
    puts $ptFaultList  
    
    
    foreach ptPort $portsList ptType $MedialTypeList ptID $IDList ptLocation $LocationList ptModel $ModelList ptStatus $StatusList \
        ptPortID $PortIDList ptSlot $SlotList ptSpeed $SpeedList ptTaskID $TaskIDList ptSwitchID $SwitchIDList  ptSwitchName $SwitchNameList ptSwitchPort $SwitchPortList {
        foreach ptFault $ptFaultList {
            if {$ptPort == $ptFault} {
                set ptStatusT 0
                break
            } else {set ptStatusT 1}
        }
        append szFault [format \{"id":"%s","location":"%s","model":"%s","status":"%s","port":"%s","slot":"%s","type":"%s","speed":"%s","taskId":"%s","switchId":"%s","name":"%s","switchPort":"%s"\}, \
                        $ptID $ptLocation $ptModel $ptStatusT $ptPortID $ptSlot $ptType $ptSpeed $ptTaskID $ptSwitchID $ptSwitchName $ptSwitchPort]
        #puts $szFault      
        
    }
    
    set szFault [string range $szFault 0 end-1]
    append szFault "]"
    return $szFault
 
    if 0 {
    set ptStatusList [split [lindex [split [stc::perform PhyVerifyLinkUp -portList $portNumList] -] 7 1]]
    puts $ptStatusList
    #set putRes
    if {[lindex $ptStatusList 0] == "All"} {
        puts "All ports have Link Up!"
        foreach ptPort $portList {
            append putRes [format "//%s/%s/%s" $ptPort [lindex $portInfo 2] [lindex $portInfo 3]]
        }
        puts "#####001,001,{}"
    } else {
        foreach ptStatus $ptStatusList {
            if {[string range $ptStatus 0 1] == {//}} {
                lappend ptFaultList $ptStatus
            }        
        }
        puts $ptFaultList
    }
    }
    #return $ptFaultList
}

;#-----------------------------------------------------------------------------------
proc analysisPcap { pcap_file_name } {
	#调用PCAP包解析脚本，返回以太网帧保留字段值
	set fid [open "$disk_file_name" "r"]
	fconfigure $fid -translation binary
    seek $fid 58 start           
    set readPcap [read $fid 4]
	close $fid
    binary scan $readPcap "H*" Reserved
    puts "$Reserved"		
	set OVF [expr {$Reserved >> 31}]
	set ART [expr {$Reserved & 0x0ffffff}]
	puts $OVF
	puts $ART
	#t1 自环固有时延
	set t1 0 
	#t2 报文转发时延
	set t2 0
	#ART1 报文内保留字段ART值
	set ART1 0
	#t3 交换延时值
	set t3 [expr 8*abs($ART - $ART1)]
	#t 交换延时累加精度
	set t [expr abs($t3 - ($t2 - $t1))]
	return $t
}


;#------------------START server.tcl-------------------------------------------------
proc Accept { newSock addr port} { 
	global sock_arr 
	puts "Accepted $newSock from $addr port $port" 
	set sock_arr(addr,$newSock) [list $addr $port] 
	puts "Now there are [expr [array size sock_arr] -1 ] client connects:\n" 
	parray sock_arr 

	fconfigure $newSock -blocking 0         ;#设置通道为非阻塞 
	fconfigure $newSock -buffering line     ;#设置 buffering 
	fileevent $newSock readable [list Echo $newSock]     ;#设置事件驱动命令 
} 
 
proc Echo {sock} {
	global EndScript
	
    puts "relllll!*****"
    
    #global sock
	if { [eof $sock] || [catch {gets $sock line}]} { 
		return 
	}  
  
	;#如果接收是 quit，则关闭对应通道套接字 
	if {[string compare $line "quit"] == 0} { 
		puts "Close $sock_arr(addr,$sock)" 
		close $sock 
		unset sock_arr(addr,$sock) 
	} 

	;#如果接收是 end，则关闭 server的套接字 
	if {[string compare $line "end"] == 0} { 
		if {[array size sock_arr] > 1} { 
			puts  "Still other clients using this server.Server's socket cannot be deleted." 
		} else { 
			puts  "Close server's socket $sock_arr(main)" 
			close $sock_arr(main) 
			unset sock_arr(main)  
		} 
	}

	set readData [read $sock]
	#puts "readData = $readData"
    
    global CHASSISSCANCMDECHO PORTSCANCMDECHO PORTSCANENDCMDECHO TESTCMDECHO ENDSCRIPTECHO
    global c_arr CHASSISSCANCMD PORTSCANCMD PORTSCANENDCMD TESTCMD ChassisIP ENDSCRIPT sock_arr 
    global remark configStr ComPort DURATION FRAME_LIST LOAD_LIST REPEAT_TIME TestList
    global TestIndex
    global PORT_LIST
    global DURATION
    global FRAME_LEN_LIST
    global TestIndex
    global t3_2_result
    global ValueList
    global PORT_LIST_COUNT
    global scanPortLoop
    global portNumList
	global tempPortsList
    
	set readDataHead [lindex [split $readData ,] 0]
	#puts "readDataHead = $readDataHead"
	if {$readDataHead == $CHASSISSCANCMD} {
        #puts $sock  "Recived \"$CHASSISSCANCMD\" command."     
        #flush $sock 
		puts "Recived \"$CHASSISSCANCMDECHO\" command."
		regexp {(?:[0-9]{1,3}\.){3}[0-9]{1,3}} $readData ChassisIP
		puts $ChassisIP
		puts "connet to $ChassisIP"
		set CardInfo [Chassis_Scan $ChassisIP]
        puts $CardInfo
        #puts $sock $CardInfo
	} elseif {$readDataHead == $PORTSCANCMD} {
        #puts $sock  "Recived \"$PORTSCANCMD\" command."     
        #flush $sock 
        puts "Recived \"$PORTSCANCMDECHO\" command."  
		set portsList [Scan_Data_Pro $readData]
        #if {$scanPortLoop == 0 || $tempPortsList != $portsList} {
			#stc::perform ChassisDisconnectAll 
			#stc::perform ResetConfig -config system1 
			set tempPortsList $portsList            
            set portNumList [Ports_Scan $portsList]                
            set scanPortLoop 1
			puts $scanPortLoop 
        #}
		set LinkDownPortsList {}
        # puts $LinkDownPortsList
        # puts "=================="
        # puts $portNumList
        # puts "===================="
        #puts [Ports_Scan_Loop $portNumList]
        set LinkDownPortsList [Ports_Scan_Loop $portNumList]
        #puts $c1 $LinkDownPortsList
        stc::perform ChassisDisconnectAll 
			stc::perform ResetConfig -config project1
        puts $LinkDownPortsList		
	} elseif {$readDataHead == $PORTSCANENDCMD} {
        #puts $sock  "Recived \"$PORTSCANENDCMD\" command."     
        #flush $sock 
        puts "Recived \"$PORTSCANENDCMDECHO\" command."   
		set scanPortLoop 0
        stc::perform ChassisDisconnectAll 
        stc::perform ResetConfig -config system1 
		puts "end port scan!"           
	} elseif {$readDataHead == $ENDSCRIPT} {
        #puts $sock  "Recived \"$ENDSCRIPT\" command."     
        #flush $sock 
        puts "Recived \"$ENDSCRIPTECHO\" command." 
		puts "End script!"
		set EndScript 1
		#return $EndScript
    } elseif {$readDataHead == "#####ok"} {
        #puts $sock  "Recived \"#####ok\" command."     
        #flush $sock 
        puts "Recived \"ok\" command."
	} elseif {$readDataHead == $TESTCMD} {
        #puts $sock  "Recived \"$TESTCMD\" command."     
        #flush $sock 
        puts "Recived \"$TESTCMDECHO\" command." 
		Test_Data_Pro $readData
		puts "start test"
        #puts $TestList
        puts $remark
		foreach testItem $TestList {
			#puts $testItem
            #puts [lindex $testItem 0]
			if {[lindex $testItem 0] == $remark} {
                set TestIndex [lindex $testItem 1]
                puts $TestIndex
				source $TestIndex   
                #puts $sock  "Finished \"[lindex $testItem 1]\" ."     
                #flush $sock 
                puts "Finished \"$TestIndex\" ." 
                break
			}
			#break
		}
		#source [dict get $TestList $remark]
	}        
} 
;#-------------------END server.tcl------------------------ 

;######################################################################################## 
global EndScript
puts "Tcl script started!"	

;#创建 server套接字（用于侦听） 
set status [catch { socket -server Accept $SERVER_PORT } ss]  
if {!$status} {   
    set sock_arr(main) $ss  
    puts "Create server socket success. Server's socket is $ss" 
} else { 
    #error "Create server's socket failed: $res" 
    puts "Create server's socket failed!" 
}


vwait EndScript
# set scanPortLoop 0
# # Create_Client c1
# # set c1 $c_arr(c1)
# # fconfigure $c1 -buffering line
# while {1} {
    # after 2000
    # #puts $c1 "Hello,I'm Client c1. Please echo me." 
    # #flush $c1
    # set readData [read $c1]   

    # puts $readData
    # set readDataHead [lindex [split $readData ,] 0]
    # #puts "readDataHead = $readDataHead"
    # if {$readDataHead == $CHASSISSCANCMD} {
        # regexp {(?:[0-9]{1,3}\.){3}[0-9]{1,3}} $readData ChassisIP
        # puts $ChassisIP
        # puts "connet to $ChassisIP"
        # Chassis_Scan $ChassisIP
    # } elseif {$readDataHead == $PORTSCANCMD} {
        # set portsList [Scan_Data_Pro $readData]
        # set portNumList [Ports_Scan $portsList]                
        # set scanPortLoop 1
    # } elseif {$readDataHead == $PORTSCANENDCMD} {
        # stc::perform chassisDisconnectAll
        # set scanPortLoop 0
        # puts "end port scan!"           
    # } elseif {$readDataHead == $ENDSCRIPT} {
        # puts "End script!"
        # break            
    # } elseif {$readDataHead == $TESTCMD} {
        # Test_Data_Pro $readData
        # puts "start test"
        # foreach testItem $TestList {
            # puts $testItem
            # if {[lindex $testItem 0] == $remark} {
                # source [lindex $testItem 1]                       
            # }
            # break
        # }
        # #source [dict get $TestList $remark]
    # }            
        
    
    # if {$scanPortLoop == 1} {
        # set LinkDownPortsList [Ports_Scan_Loop $portNumList]
        # puts $LinkDownPortsList
        # #puts $c1 $LinkDownPortsList
    # }
# }
 
# Close_Client c1

 