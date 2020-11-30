package provide StcLib 1.0

package require SpirentTestCenter


set PROJECT NONE
set RESULT_LIST {}

############################################################################
# Initial Environment, include connect chassis, create project, init port
# Input Parameter:
#       chassis_ip: chassis ip or hostname
#       port_list: port list, {{<port_location> <port_type> <port_speed>}}
#       return: port handler list
############################################################################
proc init_env { port_list } {
    global PROJECT
    # stc::config automationoptions -logTo stdout -logLevel INFO
    set PROJECT [stc::create project]
    puts $PROJECT
    foreach var $port_list {
        set port [stc::create port -under $PROJECT -location [lindex $var 0]]
        stc::create "[lindex $var 1]" \
            -under $port \
            -PriorityFlowControlArray "FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE" \
            -LineSpeed [lindex $var 2] \
            -AlternateSpeeds "" \
            -FlowControl "FALSE" \
            -Duplex "FULL" \
            -AutoNegotiation "FALSE"
        lappend port_object_list $port
    }
    stc::perform attachPorts -autoConnect true -portList [ stc::get project1 -children-Port ]
    stc::log INFO  "STEP 1: Initialize environment succeeded"
    return $port_object_list
}

############################################################################
# Release environment, relese port, disconnect chassis and so on
# port
# Input Parameter:
#       return: 
############################################################################
proc release_env { } {
    stc::perform chassisDisconnectAll 
    stc::perform resetConfig
    stc::log INFO  "STEP LAST: Release environment"
}

############################################################################
# Initial generator under ports with burst mode
# port
# Input Parameter:
#       port_handler_list: port handler list
#       return: List of generator handler
############################################################################
proc init_generator_with_burst { port_handler_list burst_size {load 100} } {
    foreach var $port_handler_list {
        set generator [stc::get $var -children-generator]
        set generator_config [stc::get $generator -children-GeneratorConfig]
        stc::config $generator_config \
            -SchedulingMode "PORT_BASED" \
            -DurationMode "BURSTS" \
            -TimestampLatchMode "END_OF_FRAME" \
            -BurstSize $burst_size \
            -FixedLoad "$load" \
            -LoadMode "FIXED" \
            -AdvancedInterleaving "FALSE" \
            -OversizeFrameThreshold "9018" \
            -UndersizeFrameThreshold "64" \
            -LoadUnit "PERCENT_LINE_RATE" \
            -InterFrameGap "12" \
            -InterFrameGapUnit "BYTES" \
            -Active "TRUE" \
            -LocalActive "TRUE" \
            -Duration "1"
        lappend generator_list $generator
    }
    stc::apply
    stc::log INFO  "Create generators succeeded"
    return $generator_list
}

############################################################################
# Initial generator under ports with duration mode
# port
# Input Parameter:
#       port_handler_list: port handler list
#       return: List of generator handler
############################################################################
proc init_generator_with_duration { port_handler_list  duration {load 100} {latch_mode "START_OF_FRAME"} {scheduling_mode "PORT_BASED"}} {
    foreach var $port_handler_list {
        set generator [stc::get $var -children-generator]
        set generator_config [stc::get $generator -children-GeneratorConfig]
        stc::config $generator_config \
            -SchedulingMode "$scheduling_mode" \
            -DurationMode "SECONDS" \
            -TimestampLatchMode "$latch_mode" \
            -FixedLoad "$load" \
            -LoadMode "FIXED" \
            -AdvancedInterleaving "FALSE" \
            -RandomLengthSeed "10900842" \
            -OversizeFrameThreshold "9018" \
            -UndersizeFrameThreshold "64" \
            -BurstSize "1" \
            -LoadUnit "PERCENT_LINE_RATE" \
            -InterFrameGap "12" \
            -InterFrameGapUnit "BYTES" \
            -Active "TRUE" \
            -LocalActive "TRUE" \
            -Duration "$duration"
        lappend generator_list $generator
    }
    stc::apply
    stc::log INFO  "Create generators succeeded"
    return $generator_list
}

proc init_generator_for_3_13 { port_handler_list  duration } {

    set generator1 [stc::get [lindex $port_handler_list 0] -children-generator]
    set generator_config1 [stc::get $generator1 -children-GeneratorConfig]
    stc::config $generator_config1 \
        -SchedulingMode "PORT_BASED" \
        -DurationMode "BURSTS" \
        -TimestampLatchMode "START_OF_FRAME" \
        -FixedLoad "10" \
        -LoadMode "FIXED" \
        -AdvancedInterleaving "FALSE" \
        -RandomLengthSeed "10900842" \
        -OversizeFrameThreshold "9018" \
        -UndersizeFrameThreshold "64" \
        -BurstSize "10" \
        -LoadUnit "PERCENT_LINE_RATE" \
        -InterFrameGap "12" \
        -InterFrameGapUnit "BYTES" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Duration "1"
    lappend generator_list $generator1

    set generator2 [stc::get [lindex $port_handler_list 2] -children-generator]
    set generator_config2 [stc::get $generator2 -children-GeneratorConfig]
    stc::config $generator_config2 \
        -SchedulingMode "PORT_BASED" \
        -DurationMode "SECONDS" \
        -TimestampLatchMode "START_OF_FRAME" \
        -FixedLoad "33" \
        -LoadMode "FIXED" \
        -AdvancedInterleaving "FALSE" \
        -RandomLengthSeed "10900842" \
        -OversizeFrameThreshold "9018" \
        -UndersizeFrameThreshold "64" \
        -BurstSize "1" \
        -LoadUnit "PERCENT_LINE_RATE" \
        -InterFrameGap "12" \
        -InterFrameGapUnit "BYTES" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Duration "$duration"
    lappend generator_list $generator2

    set generator3 [stc::get [lindex $port_handler_list 3] -children-generator]
    set generator_config3 [stc::get $generator3 -children-GeneratorConfig]
    stc::config $generator_config3 \
        -SchedulingMode "PORT_BASED" \
        -DurationMode "SECONDS" \
        -TimestampLatchMode "START_OF_FRAME" \
        -FixedLoad "33" \
        -LoadMode "FIXED" \
        -AdvancedInterleaving "FALSE" \
        -RandomLengthSeed "10900842" \
        -OversizeFrameThreshold "9018" \
        -UndersizeFrameThreshold "64" \
        -BurstSize "1" \
        -LoadUnit "PERCENT_LINE_RATE" \
        -InterFrameGap "12" \
        -InterFrameGapUnit "BYTES" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Duration "$duration"
    lappend generator_list $generator3

    set generator4 [stc::get [lindex $port_handler_list 4] -children-generator]
    set generator_config4 [stc::get $generator4 -children-GeneratorConfig]
    stc::config $generator_config4 \
        -SchedulingMode "PORT_BASED" \
        -DurationMode "SECONDS" \
        -TimestampLatchMode "START_OF_FRAME" \
        -FixedLoad "33" \
        -LoadMode "FIXED" \
        -AdvancedInterleaving "FALSE" \
        -RandomLengthSeed "10900842" \
        -OversizeFrameThreshold "9018" \
        -UndersizeFrameThreshold "64" \
        -BurstSize "1" \
        -LoadUnit "PERCENT_LINE_RATE" \
        -InterFrameGap "12" \
        -InterFrameGapUnit "BYTES" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Duration "$duration"
    lappend generator_list $generator4

    stc::apply
    stc::log INFO  "Create generators succeeded"
    return $generator_list
}

############################################################################
# Create generator statistic handlers
# port
# Input Parameter:
#       port_handler_list: port handler list
#       return: List of generator statistic handler
############################################################################
proc create_tx_statistic_handler { port_handler_list } {
    global PROJECT
    global RESULT_LIST
    foreach var $port_handler_list {
        set result_info [stc::subscribe -parent $PROJECT \
            -resultParent $var \
            -configType generator \
            -resultType generatorPortResults]
        lappend RESULT_LIST $result_info
        lappend tx_result_list [stc::get $result_info -resultHandleList]
    }
    stc::log INFO  "Create generator statistic handlers succeeded"
    return $tx_result_list
}

############################################################################
# Initial analyzer under ports
# port
# Input Parameter:
#       port_handler_list: port handler list
#       return: List of analyzer handler
############################################################################
proc init_analyzer { port_handler_list } {
    foreach var $port_handler_list {
        set analyzer [stc::get $var -children-analyzer]
        set config [stc::get $analyzer -children-AnalyzerConfig]

        stc::config $config \
            -TimestampLatchMode "START_OF_FRAME" \
            -SigMode "ENHANCED_DETECTION" \
            -HistogramMode "LATENCY" \
            -JumboFrameThreshold "1518" \
            -OversizeFrameThreshold "9018" \
            -UndersizeFrameThreshold "64" \
            -AdvSeqCheckerLateThreshold "1000" \
            -VlanAlternateTpid "34984" \
            -AlternateSigOffset "0" \
            -LatencyMode "PER_STREAM_RX_LATENCY_ON" \
            -Active "TRUE" \
            -LocalActive "TRUE"

        # set intv [stc::get $config -children-InterarrivalTimeHistogram]
        # stc::config $intv \
        #     -Description {(ns)} \
        #     -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        #     -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        #     -DistributionMode "CUSTOM_MODE" \
        #     -ConfigMode "CONFIG_SIZE_MODE" \
        #     -DistributionModeSize "1024" \
        #     -UniformDistributionSize "8" \
        #     -CenterPoint "568" \
        #     -BucketSizeUnit "TEN_NANOSECONDS" \
        #     -Active "TRUE" \
        #     -LocalActive "TRUE"

        # set latHist [stc::get $config -children-LatencyHistogram]
        # stc::config $latHist \
        #         -Description {(ns)} \
        #         -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        #         -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        #         -DistributionMode "CUSTOM_MODE" \
        #         -ConfigMode "CONFIG_SIZE_MODE" \
        #         -DistributionModeSize "1024" \
        #         -UniformDistributionSize "8" \
        #         -CenterPoint "568" \
        #         -BucketSizeUnit "TEN_NANOSECONDS" \
        #         -Active "TRUE" \
        #         -LocalActive "TRUE"

        # set flHist [stc::get $config -children-FrameLengthHistogram]
        # stc::config $flHist \
        #         -Description {(in bytes)} \
        #         -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        #         -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        #         -DistributionMode "CUSTOM_MODE" \
        #         -ConfigMode "CONFIG_SIZE_MODE" \
        #         -DistributionModeSize "1024" \
        #         -UniformDistributionSize "8" \
        #         -CenterPoint "568" \
        #         -BucketSizeUnit "TEN_NANOSECONDS" \
        #         -Active "TRUE" \
        #         -LocalActive "TRUE"
        
        # set jitterHist [stc::get $config -children-JitterHistogram]
        # stc::config $jitterHist \
        #         -Description {(ns)} \
        #         -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        #         -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        #         -DistributionMode "CUSTOM_MODE" \
        #         -ConfigMode "CONFIG_SIZE_MODE" \
        #         -DistributionModeSize "1024" \
        #         -UniformDistributionSize "8" \
        #         -CenterPoint "568" \
        #         -BucketSizeUnit "TEN_NANOSECONDS" \
        #         -Active "TRUE" \
        #         -LocalActive "TRUE"
        
        # set sampleingPortConf [stc::get $analyzer -children-HighResolutionSamplingPortConfig]
        # stc::config $sampleingPortConf \
        #         -BaselineSampleCount "3" \
        #         -EnableTrigger "TRUE" \
        #         -TriggerCondition "LESS_THAN" \
        #         -TriggerValueUnitMode "PERCENT_BASELINE" \
        #         -TriggerStat {TotalFrameRate} \
        #         -TriggerValue "95" \
        #         -TriggerLocation "20" \
        #         -TimingMode "INTERVAL" \
        #         -SamplingInterval "10" \
        #         -SamplingDuration "10" \
        #         -Active "TRUE" \
        #         -LocalActive "TRUE"

        # set hrStreamConf [stc::create "HighResolutionStreamBlockOptions" \
        #         -under $analyzer \
        #         -TimingMode "INTERVAL" \
        #         -SamplingInterval "10" \
        #         -SamplingDuration "10" \
        #         -Active "TRUE" \
        #         -LocalActive "TRUE" ]

        set InterarrivalTimeHistogram(2) [lindex [stc::get $config -children-InterarrivalTimeHistogram] 0]
        stc::config $InterarrivalTimeHistogram(2) \
        -Description {(ns)} \
        -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        -DistributionMode "CUSTOM_MODE" \
        -ConfigMode "CONFIG_SIZE_MODE" \
        -DistributionModeSize "1024" \
        -UniformDistributionSize "8" \
        -CenterPoint "568" \
        -BucketSizeUnit "TEN_NANOSECONDS" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {Histograms 39}

    set LatencyHistogram(2) [lindex [stc::get $config -children-LatencyHistogram] 0]
    stc::config $LatencyHistogram(2) \
        -Description {(ns)} \
        -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        -DistributionMode "CUSTOM_MODE" \
        -ConfigMode "CONFIG_SIZE_MODE" \
        -DistributionModeSize "1024" \
        -UniformDistributionSize "8" \
        -CenterPoint "568" \
        -BucketSizeUnit "TEN_NANOSECONDS" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {Histograms 39}

set FrameLengthHistogram(2) [lindex [stc::get $config -children-FrameLengthHistogram] 0]
stc::config $FrameLengthHistogram(2) \
        -Description {(in bytes)} \
        -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        -DistributionMode "CUSTOM_MODE" \
        -ConfigMode "CONFIG_SIZE_MODE" \
        -DistributionModeSize "1024" \
        -UniformDistributionSize "8" \
        -CenterPoint "568" \
        -BucketSizeUnit "TEN_NANOSECONDS" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {Histograms 39}

    set SeqRunLengthHistogram(2) [lindex [stc::get $config -children-SeqRunLengthHistogram] 0]
    stc::config $SeqRunLengthHistogram(2) \
        -Description {(in frames)} \
        -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        -DistributionMode "CUSTOM_MODE" \
        -ConfigMode "CONFIG_SIZE_MODE" \
        -DistributionModeSize "1024" \
        -UniformDistributionSize "8" \
        -CenterPoint "568" \
        -BucketSizeUnit "TEN_NANOSECONDS" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {Histograms 39}

    set SeqDiffCheckHistogram(2) [lindex [stc::get $config -children-SeqDiffCheckHistogram] 0]
    stc::config $SeqDiffCheckHistogram(2) \
        -Description {(in deltas)} \
        -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        -DistributionMode "CUSTOM_MODE" \
        -ConfigMode "CONFIG_SIZE_MODE" \
        -DistributionModeSize "1024" \
        -UniformDistributionSize "8" \
        -CenterPoint "568" \
        -BucketSizeUnit "TEN_NANOSECONDS" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {Histograms 39}

    set JitterHistogram(2) [lindex [stc::get $config -children-JitterHistogram] 0]
    stc::config $JitterHistogram(2) \
        -Description {(ns)} \
        -BucketSizeList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536" \
        -LimitList "2 6 14 30 62 126 254 510 1022 2046 4094 8190 16382 32766 65534" \
        -DistributionMode "CUSTOM_MODE" \
        -ConfigMode "CONFIG_SIZE_MODE" \
        -DistributionModeSize "1024" \
        -UniformDistributionSize "8" \
        -CenterPoint "568" \
        -BucketSizeUnit "TEN_NANOSECONDS" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {Histograms 39}

    set DiffServConfig(2) [lindex [stc::get $analyzer -children-DiffServConfig] 0]
    stc::config $DiffServConfig(2) \
        -QualifyIpv6DstAddr "FALSE" \
        -Ipv6DstAddr "ffff::ffff" \
        -QualifyIpv4DstAddr "FALSE" \
        -Ipv4DstAddr "0.0.0.0" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {QoS Settings 39}

    set HighResolutionSamplingPortConfig(2) [lindex [stc::get $analyzer -children-HighResolutionSamplingPortConfig] 0]
    stc::config $HighResolutionSamplingPortConfig(2) \
        -BaselineSampleCount "3" \
        -EnableTrigger "TRUE" \
        -TriggerCondition "LESS_THAN" \
        -TriggerValueUnitMode "PERCENT_BASELINE" \
        -TriggerStat {TotalFrameRate} \
        -TriggerValue "95" \
        -TriggerLocation "20" \
        -TimingMode "INTERVAL" \
        -SamplingInterval "10" \
        -SamplingDuration "10" \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {High Resolution Port Sampling 39}

        lappend analyzer_list $analyzer
    }
    stc::apply
    stc::log INFO  "Create analyzers succeeded"
    return $analyzer_list
}

############################################################################
# Create analyzer statistic handlers
# port
# Input Parameter:
#       port_handler_list: port handler list
#       return: List of analyzer statistic handler
############################################################################
proc create_rx_statistic_handler { port_handler_list } {
    global PROJECT
    global RESULT_LIST
    foreach var $port_handler_list {
        set result_info [stc::subscribe -parent $PROJECT \
            -resultParent $var \
            -configType analyzer \
            -resultType analyzerPortResults]
        lappend RESULT_LIST $result_info
        stc::sleep 1
        lappend rx_result_list [stc::get $result_info  -resultHandleList]
    }
    stc::log INFO  "Create analyzer statistic handlers succeeded"
    return $rx_result_list
}

############################################################################
# Start analyzers
# port
# Input Parameter:
#       analyzer_list: analyzer handler list
#       return: 
############################################################################
proc start_analyzer_list { analyzer_list } {
    stc::perform analyzerStart -analyzerList $analyzer_list
    # stc::sleep 2
    stc::log INFO  "Start analyzers succeeded"
}

############################################################################
# Start generators
# port
# Input Parameter:
#       generator_list: generator handler list
#       return: 
############################################################################
proc start_generator_list { generator_list } {
    stc::perform generatorStart -generatorList $generator_list
    stc::log INFO  "Start generators succeeded"
}

############################################################################
# Initialize streams
# port
# Input Parameter:
#       port_handler_list: port handler list
#       return: stream list
############################################################################
proc init_stream { port_handler_list {frame_length 128} {load 100} } {
    global PROJECT
    set len [llength $port_handler_list]
    for {set index 0} {$index < $len} {incr index} {
        # set streamBlock [stc::create streamBlock  -under [lindex $port_handler_list $index] \
        #                     -FixedFrameLength $frame_length \
        #                     -ControlledBy {generator} \
        #                     -TrafficPattern "PAIR" \
        #                     -EnableStreamOnlyGeneration "TRUE" \
        #                     -EnableBidirectionalTraffic "FALSE" \
        #                     -EqualRxPortDistribution "FALSE" \
        #                     -EnableTxPortSendingTrafficToSelf "FALSE" \
        #                     -EnableControlPlane "FALSE" \
        #                     -InsertSig "TRUE" \
        #                     -FrameLengthMode "FIXED" \
        #                     -IsControlledByGenerator "TRUE" \
        #                     -FillType "CONSTANT" \
        #                     -ConstantFillPattern "0" \
        #                     -EnableHighSpeedResultAnalysis "TRUE" \
        #                     -EnableFcsErrorInsertion "FALSE" \
        #                     -load $load] 
        set streamBlock [stc::create "StreamBlock" \
            -under [lindex $port_handler_list $index] \
            -IsControlledByGenerator "TRUE" \
            -ControlledBy {generator} \
            -TrafficPattern "PAIR" \
            -EndpointMapping "ONE_TO_ONE" \
            -EnableStreamOnlyGeneration "FALSE" \
            -EnableBidirectionalTraffic "FALSE" \
            -EqualRxPortDistribution "FALSE" \
            -EnableTxPortSendingTrafficToSelf "FALSE" \
            -EnableControlPlane "FALSE" \
            -InsertSig "TRUE" \
            -FrameLengthMode "FIXED" \
            -FixedFrameLength "$frame_length" \
            -MinFrameLength "128" \
            -MaxFrameLength "256" \
            -StepFrameLength "1" \
            -FillType "CONSTANT" \
            -ConstantFillPattern "0" \
            -EnableFcsErrorInsertion "FALSE" \
            -Filter {MPLS-TP,Bfd,Rip,Lldp,Ieee1588v2,Bgp,Isis,Ldp,Stp,Ospfv3,Lacp,Pim,Rsvp,Ospfv2,FCoE,FCPlugin,FCoEVFPort,FCFPort,TwampClient,TwampServer,LspPing,Lisp,Otv,Openflow Protocol,VXLAN Protocol,PppoeProtocol,Ancp,PppProtocol,802.1x,Trill Protocol,Vepa,Packet Channel,SyncE,Dhcpv4,Dhcpv6,Cifs,Http,RawTcp,Sip,Ftp,Dpg,Video,XMPPvJ,CSMP} \
            -ShowAllHeaders "FALSE" \
            -AllowInvalidHeaders "FALSE" \
            -AutoSelectTunnel "FALSE" \
            -ByPassSimpleIpSubnetChecking "FALSE" \
            -EnableHighSpeedResultAnalysis "TRUE" \
            -EnableBackBoneTrafficSendToSelf "TRUE" \
            -EnableResolveDestMacAddress "TRUE" \
            -AdvancedInterleavingGroup "0" \
            -Active "TRUE" \
            -LocalActive "TRUE" \
            -load $load ]

        lappend stream_list $streamBlock

        set ethhead [stc::get $streamBlock -children-ethernet:EthernetII]
        stc::config $ethhead -srcMac [get_port_mac [lindex $port_handler_list $index]]
        set last_index [expr $len-1]
        if {$index == $last_index} {
            stc::config $ethhead -dstMac [get_port_mac [lindex $port_handler_list 0]]
        } else {
            set next_index [expr $index+1]
            stc::config $ethhead -dstMac [get_port_mac [lindex $port_handler_list $next_index]]
        }
        #set the ip address too.you can configure multipe atrributes at once.
        #stc::config $ip4head -sourceAddr "192.85.1.3" -destAddr "192.85.1.4"
        #send the configuration to the chassis
        stc::apply  
    }

    set Rfc2544LatencyConfig [stc::create "Rfc2544LatencyConfig" \
            -under $PROJECT \
            -NumOfTrials "1" \
            -DurationSeconds "60" \
            -LoadUnits "PERCENT_LINE_RATE" \
            -LoadType "CUSTOM" \
            -LoadStart "10" \
            -LoadEnd "50" \
            -LoadStep "10" \
            -RandomMinLoad "10" \
            -RandomMaxLoad "50" \
            -CustomLoadList "95 10" \
            -LatencyDistributionList "2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65535" \
            -UseThroughputRates "FALSE" \
            -ThroughputRatePercent "100" \
            -ProfileConfigMode "MANUAL" \
            -ProfileConfigGroupType {} \
            -DurationMode "SECONDS" \
            -DurationBursts "1000" \
            -FrameSizeIterationMode "CUSTOM" \
            -RandomMinFrameSize "128" \
            -RandomMaxFrameSize "256" \
            -FrameSizeStart "128" \
            -FrameSizeEnd "256" \
            -FrameSizeStep "128" \
            -CustomFrameSizeList "64 65 128 256 512 1024 1280 1518" \
            -ImixDistributionString {} \
            -UseExistingStreamBlocks "TRUE" \
            -LearningMode "L2_LEARNING" \
            -L3Rate "1000" \
            -L3RetryCount "5" \
            -L3EnableCyclicAddrResolution "TRUE" \
            -EnablePauseBeforeTraffic "FALSE" \
            -StaggerStartDelay "0" \
            -DelayAfterTransmission "15" \
            -TrafficStartDelay "2" \
            -TrafficStartDelayMode "AFTER_TEST" \
            -EnableFrameSizeOnTest "TRUE" \
            -LatencyType "LIFO" \
            -EnableLearning "TRUE" \
            -L2DelayBeforeLearning "2" \
            -L3DelayBeforeLearning "2" \
            -LearningFreqMode "LEARN_EVERY_FRAME_SIZE" \
            -L2LearningFrameRate "1000" \
            -L2LearningRepeatCount "5" \
            -L2FrameSizeMode "SAME_AS_STREAM" \
            -L2FixedFrameSize "128" \
            -EnableTrafficVerification "FALSE" \
            -TrafficVerificationFreqMode "VERIFY_EVERY_ITERATION" \
            -TrafficVerificationAbortOnFail "TRUE" \
            -TrafficVerificationTxFrameCount "100" \
            -TrafficVerificationTxFrameRate "1000" \
            -EnableDetailedResultsCollection "TRUE" \
            -EnableJitterMeasurement "TRUE" \
            -EnableOfferedLoad "FALSE" \
            -EnableExposedInternalCommands "TRUE" \
            -DisplayLoadUnit "PERCENT_LINE_RATE" \
            -DisplayTrafficGroupLoadUnit "PERCENT_LINE_RATE" \
            -Active "TRUE" \
            -LocalActive "TRUE" \
            -Name {Rfc2544LatencyConfig 1} ]

    set Rfc2544StreamBlockProfile [stc::create "Rfc2544StreamBlockProfile" \
            -under $Rfc2544LatencyConfig \
            -Active "TRUE" \
            -LocalActive "TRUE" \
            -Name {Rfc2544StreamBlockProfile 1} ]
    stc::config $Rfc2544StreamBlockProfile -StreamBlockList $stream_list

    return $stream_list
}

############################################################################
# Initialize fullmesh streams
# port
# Input Parameter:
#       port_handler_list: port handler list
#       return: stream list
############################################################################
proc init_fullmesh_stream { port_handler_list {frame_length 128} {load 100} } {

    set len [llength $port_handler_list]
    for {set index1 0} {$index1 < $len} {incr index1} {
        for {set index2 0} {$index2 < $len} {incr index2} {
            if {$index1 != $index2} {
                puts "SrcMac [get_port_mac [lindex $port_handler_list $index1]]  ->  DstMac [get_port_mac [lindex $port_handler_list $index2]]"
                set streamBlock [stc::create streamBlock  -under [lindex $port_handler_list $index1] \
                            -FixedFrameLength $frame_length \
                            -ControlledBy {generator} \
                            -TrafficPattern "PAIR" \
                            -EnableStreamOnlyGeneration "TRUE" \
                            -EnableBidirectionalTraffic "FALSE" \
                            -EqualRxPortDistribution "FALSE" \
                            -EnableTxPortSendingTrafficToSelf "FALSE" \
                            -EnableControlPlane "FALSE" \
                            -InsertSig "TRUE" \
                            -FrameLengthMode "FIXED" \
                            -IsControlledByGenerator "TRUE" \
                            -FillType "CONSTANT" \
                            -ConstantFillPattern "0" \
                            -EnableHighSpeedResultAnalysis "TRUE" \
                            -EnableFcsErrorInsertion "FALSE" \
                            -load $load] 
                lappend stream_list $streamBlock

                set ethhead [stc::get $streamBlock -children-ethernet:EthernetII]
                stc::config $ethhead -srcMac [get_port_mac [lindex $port_handler_list $index1]] \
                    -dstMac [get_port_mac [lindex $port_handler_list $index2]]
                stc::apply     
            }
        }
        
        #set the ip address too.you can configure multipe atrributes at once.
        #stc::config $ip4head -sourceAddr "192.85.1.3" -destAddr "192.85.1.4"
        #send the configuration to the chassis 
    }
    return $stream_list
}

proc init_single_stream { src_port dst_port {frame_length 128} {load 100} } {
    puts "[stc::get $src_port -location] SrcMac [get_port_mac $src_port]  -> [stc::get $src_port -location] DstMac: [get_port_mac $dst_port]"
    set streamBlock [stc::create streamBlock  -under $src_port \
                -FixedFrameLength $frame_length \
                -ControlledBy {generator} \
                -TrafficPattern "PAIR" \
                -EnableStreamOnlyGeneration "TRUE" \
                -EnableBidirectionalTraffic "FALSE" \
                -EqualRxPortDistribution "FALSE" \
                -EnableTxPortSendingTrafficToSelf "FALSE" \
                -EnableControlPlane "FALSE" \
                -InsertSig "TRUE" \
                -FrameLengthMode "FIXED" \
                -IsControlledByGenerator "TRUE" \
                -FillType "CONSTANT" \
                -ConstantFillPattern "0" \
                -EnableHighSpeedResultAnalysis "TRUE" \
                -EnableFcsErrorInsertion "FALSE" \
                -load $load] 

    set ethhead [stc::get $streamBlock -children-ethernet:EthernetII]
    stc::config $ethhead -srcMac [get_port_mac $src_port] \
        -dstMac [get_port_mac $dst_port]
    stc::apply     
    return $streamBlock
}

#针对2.12 vlan tag测试，生成9条stream block
proc init_2_12_stream { port2 } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:01:01:07</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType></pdu><pdu name="custom_112561" pdu="custom:Custom"><pattern>01070008000000005a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {GOOSE NO VID} ]

    set StreamBlock(2) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:01:01:07</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType><vlans name="anon_122894"><Vlan name="Vlan"><pri>000</pri><id>1</id></Vlan></vlans></pdu><pdu name="custom_112586" pdu="custom:Custom"><pattern>01070008000000005a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {GOOSE VID1} ]

    set StreamBlock(3) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:01:01:07</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType><vlans name="anon_122899"><Vlan name="Vlan"><pri>000</pri><id>10</id></Vlan></vlans></pdu><pdu name="custom_114829" pdu="custom:Custom"><pattern>01070008000000005a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {GOOSE VID10} ]

    set StreamBlock(4) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:01:01:07</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType><vlans name="anon_122904"><Vlan name="Vlan"><pri>000</pri><id>20</id></Vlan></vlans></pdu><pdu name="custom_115206" pdu="custom:Custom"><pattern>01070008000000005a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {GOOSE VID20} ]

    set StreamBlock(5) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:00:01:00:00:01</dstMac><srcMac>00:00:01:01:01:01</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_122911"><tos name="anon_122912"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {IPV4 NO VID} ]

    set StreamBlock(6) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:00:01:00:00:01</dstMac><srcMac>00:00:01:01:01:01</srcMac><vlans name="anon_122917"><Vlan name="Vlan"><pri>000</pri><id>1</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_122920"><tos name="anon_122921"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {IPV4 VID1} ]

    set StreamBlock(7) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:00:01:00:00:01</dstMac><srcMac>00:00:01:01:01:01</srcMac><vlans name="anon_122926"><Vlan name="Vlan"><pri>000</pri><id>10</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_122929"><tos name="anon_122930"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {IPV4 VID10} ]

    set StreamBlock(8) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:00:01:00:00:01</dstMac><srcMac>00:00:01:01:01:01</srcMac><vlans name="anon_122935"><Vlan name="Vlan"><pri>000</pri><id>20</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_122938"><tos name="anon_122939"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {IPV4 VID20} ]

    set StreamBlock(9) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>FF:FF:FF:FF:FF:FF</dstMac><srcMac>00:00:01:01:01:01</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_122946"><tos name="anon_122947"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {BROADCAST NO VID} ]
    
    stc::apply

    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)
    lappend stream_block_list $StreamBlock(3)
    lappend stream_block_list $StreamBlock(4)
    lappend stream_block_list $StreamBlock(5)
    lappend stream_block_list $StreamBlock(6)
    lappend stream_block_list $StreamBlock(7)
    lappend stream_block_list $StreamBlock(8)
    lappend stream_block_list $StreamBlock(9)
    return $stream_block_list
}

#针对2.1 帧过滤测试，生成4条stream block
proc init_2_1_stream { port2 } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:10:94:00:00:03</dstMac><srcMac>00:00:01:01:01:01</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_2385"><tos name="anon_2386"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {ok} ]

    set StreamBlock(2) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "TRUE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:10:94:00:00:03</dstMac><srcMac>00:00:01:01:01:01</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_2393"><tos name="anon_2394"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {fcs} ]

    set StreamBlock(3) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "2000" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:10:94:00:00:03</dstMac><srcMac>00:00:01:01:01:01</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><tosDiffserv name="anon_2401"><tos name="anon_2402"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {long} ]

    set StreamBlock(4) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "58" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:10:94:00:00:03</dstMac><srcMac>00:00:01:01:01:01</srcMac></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {short} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)
    lappend stream_block_list $StreamBlock(3)
    lappend stream_block_list $StreamBlock(4)
    return $stream_block_list
}

#针对2.4 帧过滤测试
proc init_2_4_stream { port_object_list } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 0] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><srcMac>01:10:94:00:00:02</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_2466"><tos name="anon_2467"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {error src} ]

    set StreamBlock(2) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 0] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "TRUE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><tosDiffserv name="anon_2474"><tos name="anon_2475"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {error crc} ]

    set StreamBlock(3) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 0] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:10:00:00:00:01</dstMac><srcMac>00:01:00:00:00:02</srcMac></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {1 - 2} ]
    
    set StreamBlock(4) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 1] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {Device,MPLS-TP,Bfd,Rip,Lldp,Ieee1588v2,Bgp,Isis,Ldp,Stp,Ospfv3,Lacp,Pim,Rsvp,Ospfv2,FCoE,FCPlugin,FCoEVFPort,FCFPort,TwampClient,TwampServer,LspPing,Lisp,Otv,Openflow Protocol,VXLAN Protocol,PppoeProtocol,Ancp,PppProtocol,802.1x,Trill Protocol,Vepa,Packet Channel,SyncE,Dhcpv4,Dhcpv6,Cifs,Http,RawTcp,Sip,Ftp,Dpg,Video,XMPPvJ,CSMP,IPv4} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:10:00:00:00:03</dstMac><srcMac>00:01:00:00:00:02</srcMac></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {2-1} ]
    
    set StreamBlock(5) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 2] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {Device,MPLS-TP,Bfd,Rip,Lldp,Ieee1588v2,Bgp,Isis,Ldp,Stp,Ospfv3,Lacp,Pim,Rsvp,Ospfv2,FCoE,FCPlugin,FCoEVFPort,FCFPort,TwampClient,TwampServer,LspPing,Lisp,Otv,Openflow Protocol,VXLAN Protocol,PppoeProtocol,Ancp,PppProtocol,802.1x,Trill Protocol,Vepa,Packet Channel,SyncE,Dhcpv4,Dhcpv6,Cifs,Http,RawTcp,Sip,Ftp,Dpg,Video,XMPPvJ,CSMP,IPv4} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:11:00:00:00:05</dstMac><srcMac>00:11:00:00:00:04</srcMac></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {3-4} ]
    
    set StreamBlock(6) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 3] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {Device,MPLS-TP,Bfd,Rip,Lldp,Ieee1588v2,Bgp,Isis,Ldp,Stp,Ospfv3,Lacp,Pim,Rsvp,Ospfv2,FCoE,FCPlugin,FCoEVFPort,FCFPort,TwampClient,TwampServer,LspPing,Lisp,Otv,Openflow Protocol,VXLAN Protocol,PppoeProtocol,Ancp,PppProtocol,802.1x,Trill Protocol,Vepa,Packet Channel,SyncE,Dhcpv4,Dhcpv6,Cifs,Http,RawTcp,Sip,Ftp,Dpg,Video,XMPPvJ,CSMP,IPv4} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:11:00:00:00:04</dstMac><srcMac>00:11:00:00:00:05</srcMac></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {4-3} ]
    


    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)
    lappend stream_block_list $StreamBlock(3)
    lappend stream_block_list $StreamBlock(4)
    lappend stream_block_list $StreamBlock(5)
    lappend stream_block_list $StreamBlock(6)
    return $stream_block_list
}

#针对2.5 mac绑定测试
proc init_2_5_stream { port2 static_mac } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig [format {<frame  valid="false" ><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:00:01:00:00:03</dstMac><srcMac>%s</srcMac></pdu></pdus></config></frame>} $static_mac] \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {normal stream} ]
    
    set StreamBlock(2) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {Device,MPLS-TP,Bfd,Rip,Lldp,Ieee1588v2,Bgp,Isis,Ldp,Stp,Ospfv3,Lacp,Pim,Rsvp,Ospfv2,FCoE,FCPlugin,FCoEVFPort,FCFPort,TwampClient,TwampServer,LspPing,Lisp,Otv,Openflow Protocol,VXLAN Protocol,PppoeProtocol,Ancp,PppProtocol,802.1x,Trill Protocol,Vepa,Packet Channel,SyncE,Dhcpv4,Dhcpv6,Cifs,Http,RawTcp,Sip,Ftp,Dpg,Video,XMPPvJ,CSMP,IPv4} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:00:01:00:00:02</dstMac><srcMac>00:01:01:00:00:05</srcMac></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {error stream} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)

    return $stream_block_list
}

#针对2.11 广播抑制测试
proc init_2_11_stream { port2 } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>01:00:01:00:00:01</dstMac><srcMac>[get_port_mac $port2]</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_3805"><tos name="anon_3806"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {multicast} ]

    set StreamBlock(2) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:01:00:00:00:00</dstMac><srcMac>[get_port_mac $port2]</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_3813"><tos name="anon_3814"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {unicast} ]

    set StreamBlock(3) [stc::create "StreamBlock" \
        -under $port2 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>FF:FF:FF:FF:FF:FF</dstMac><srcMac>[get_port_mac $port2]</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_3821"><tos name="anon_3822"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {broadcast} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)
    lappend stream_block_list $StreamBlock(3)
    
    return $stream_block_list
}

#针对2.14 优先级测试，配置学习帧
proc init_2_14_learn_stream { port5 } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under $port5 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>FF:FF:FF:FF:FF:FF</dstMac><srcMac>00:05:00:00:00:01</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_3805"><tos name="anon_3806"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {learn} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)    
    return $stream_block_list
}

#针对2.14 优先级测试
proc init_2_14_stream { port_list } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under [lindex $port_list 0] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "256" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:05:00:00:00:01</dstMac><srcMac>00:01:00:00:00:01</srcMac><vlans name="anon_6557"><Vlan name="Vlan"><pri>001</pri><id>1</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_6560"><tos name="anon_6561"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {1} ]

    set StreamBlock(2) [stc::create "StreamBlock" \
        -under [lindex $port_list 1] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "256" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:05:00:00:00:01</dstMac><srcMac>00:02:00:00:00:01</srcMac><vlans name="anon_6557"><Vlan name="Vlan"><pri>011</pri><id>1</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_6560"><tos name="anon_6561"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {2} ]
    
    set StreamBlock(3) [stc::create "StreamBlock" \
        -under [lindex $port_list 2] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "256" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:05:00:00:00:01</dstMac><srcMac>00:03:00:00:00:01</srcMac><vlans name="anon_6557"><Vlan name="Vlan"><pri>101</pri><id>1</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_6560"><tos name="anon_6561"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {3} ]

    set StreamBlock(4) [stc::create "StreamBlock" \
        -under [lindex $port_list 3] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "256" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:05:00:00:00:01</dstMac><srcMac>00:04:00:00:00:01</srcMac><vlans name="anon_6557"><Vlan name="Vlan"><pri>111</pri><id>1</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_6560"><tos name="anon_6561"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {4} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)
    lappend stream_block_list $StreamBlock(3)
    lappend stream_block_list $StreamBlock(4)
    
    return $stream_block_list
}

#针对3.9 静态组播测试
proc init_3_9_stream { port1 start_mac multicast_num} {
    puts [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>%s</dstMac><srcMac>%s</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_15413"><tos name="anon_15414"></tos></tosDiffserv></pdu></pdus></config></frame>} $start_mac [get_port_mac $port1]]
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under $port1 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>%s</dstMac><srcMac>%s</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_15413"><tos name="anon_15414"></tos></tosDiffserv></pdu></pdus></config></frame>} $start_mac [get_port_mac $port1]]\
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {512} ]

set RangeModifier(1) [stc::create "RangeModifier" \
        -under $StreamBlock(1) \
        -ModifierMode "INCR" \
        -Mask {00:00:FF:FF:FF:FF} \
        -StepValue {00:00:00:00:00:01} \
        -RecycleCount $multicast_num \
        -RepeatCount "0" \
        -Data $start_mac \
        -DataType "NATIVE" \
        -EnableStream "FALSE" \
        -Offset "2" \
        -OffsetReference {eth1.dstMac} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {MAC Modifier} ]

set StreamBlock(2) [stc::create "StreamBlock" \
        -under $port1 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>01:00:5E:10:00:01</dstMac><srcMac>%s</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_15569"><tos name="anon_15570"></tos></tosDiffserv></pdu></pdus></config></frame>} [get_port_mac $port1]] \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {01:00:5E:10:00:01} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)
    
    return $stream_block_list
}

proc config_3_13_stream {stream config} {
    stc::config $stream -frameConfig $config
}

#针对3.13 交换时延测试
proc init_3_13_stream { port_object_list} {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 0] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:04:00:05</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_2162" pdu="custom:Custom"><pattern>4003003000000000608167800101A2816130815E800430303030820208598304000000018501018781480000000000000000</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {64  ART0x00} ]

    set StreamBlock(2) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 2] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {Device,MPLS-TP,Bfd,Rip,Lldp,Ieee1588v2,Bgp,Isis,Ldp,Stp,Ospfv3,Lacp,Pim,Rsvp,Ospfv2,FCoE,FCPlugin,FCoEVFPort,FCFPort,TwampClient,TwampServer,LspPing,Lisp,Otv,Openflow Protocol,VXLAN Protocol,PppoeProtocol,Ancp,PppProtocol,802.1x,Trill Protocol,Vepa,Packet Channel,SyncE,Dhcpv4,Dhcpv6,Cifs,Http,RawTcp,Sip,Ftp,Dpg,Video,XMPPvJ,CSMP,IPv4} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>%s</dstMac><srcMac>%s</srcMac><vlans name="anon_6557"><Vlan name="Vlan"><pri>111</pri><id>1</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_6560"><tos name="anon_6561"></tos></tosDiffserv></pdu></pdus></config></frame>} [get_port_mac [lindex $port_object_list 1]] [get_port_mac [lindex $port_object_list 2]] ] \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {StreamBlock 9-4} ]
    
    set StreamBlock(3) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 3] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {Device,MPLS-TP,Bfd,Rip,Lldp,Ieee1588v2,Bgp,Isis,Ldp,Stp,Ospfv3,Lacp,Pim,Rsvp,Ospfv2,FCoE,FCPlugin,FCoEVFPort,FCFPort,TwampClient,TwampServer,LspPing,Lisp,Otv,Openflow Protocol,VXLAN Protocol,PppoeProtocol,Ancp,PppProtocol,802.1x,Trill Protocol,Vepa,Packet Channel,SyncE,Dhcpv4,Dhcpv6,Cifs,Http,RawTcp,Sip,Ftp,Dpg,Video,XMPPvJ,CSMP,IPv4} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>%s</dstMac><srcMac>%s</srcMac><vlans name="anon_6557"><Vlan name="Vlan"><pri>111</pri><id>1</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_6560"><tos name="anon_6561"></tos></tosDiffserv></pdu></pdus></config></frame>} [get_port_mac [lindex $port_object_list 1]] [get_port_mac [lindex $port_object_list 3]] ] \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {StreamBlock 9-5} ]

    set StreamBlock(4) [stc::create "StreamBlock" \
        -under [lindex $port_object_list 4] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {Device,MPLS-TP,Bfd,Rip,Lldp,Ieee1588v2,Bgp,Isis,Ldp,Stp,Ospfv3,Lacp,Pim,Rsvp,Ospfv2,FCoE,FCPlugin,FCoEVFPort,FCFPort,TwampClient,TwampServer,LspPing,Lisp,Otv,Openflow Protocol,VXLAN Protocol,PppoeProtocol,Ancp,PppProtocol,802.1x,Trill Protocol,Vepa,Packet Channel,SyncE,Dhcpv4,Dhcpv6,Cifs,Http,RawTcp,Sip,Ftp,Dpg,Video,XMPPvJ,CSMP,IPv4} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>%s</dstMac><srcMac>%s</srcMac><vlans name="anon_6557"><Vlan name="Vlan"><pri>111</pri><id>1</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_6560"><tos name="anon_6561"></tos></tosDiffserv></pdu></pdus></config></frame>} [get_port_mac [lindex $port_object_list 1]] [get_port_mac [lindex $port_object_list 4]] ] \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {StreamBlock 9-6} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)
    lappend stream_block_list $StreamBlock(3)
    lappend stream_block_list $StreamBlock(4)
    
    return $stream_block_list
}

#针对3.9 静态组播测试
# proc init_3_9_stream { port1 start_mac multicast_num} {
#     set StreamBlock(1) [stc::create "StreamBlock" \
#         -under $port1 \
#         -IsControlledByGenerator "TRUE" \
#         -ControlledBy {generator} \
#         -TrafficPattern "PAIR" \
#         -EndpointMapping "ONE_TO_ONE" \
#         -EnableStreamOnlyGeneration "TRUE" \
#         -EnableBidirectionalTraffic "FALSE" \
#         -EqualRxPortDistribution "FALSE" \
#         -EnableTxPortSendingTrafficToSelf "FALSE" \
#         -EnableControlPlane "FALSE" \
#         -InsertSig "TRUE" \
#         -FrameLengthMode "FIXED" \
#         -FixedFrameLength "128" \
#         -MinFrameLength "128" \
#         -MaxFrameLength "256" \
#         -StepFrameLength "1" \
#         -FillType "CONSTANT" \
#         -ConstantFillPattern "0" \
#         -EnableFcsErrorInsertion "FALSE" \
#         -Filter {} \
#         -ShowAllHeaders "FALSE" \
#         -AllowInvalidHeaders "FALSE" \
#         -AutoSelectTunnel "FALSE" \
#         -ByPassSimpleIpSubnetChecking "FALSE" \
#         -EnableHighSpeedResultAnalysis "TRUE" \
#         -EnableBackBoneTrafficSendToSelf "TRUE" \
#         -EnableResolveDestMacAddress "TRUE" \
#         -AdvancedInterleavingGroup "0" \
#         -FrameConfig [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>%s</dstMac><srcMac>%s</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_15413"><tos name="anon_15414"></tos></tosDiffserv></pdu></pdus></config></frame>} $start_mac [get_port_mac $port1]] \
#         -Active "FALSE" \
#         -LocalActive "TRUE" \
#         -Name {512} ]

# set RangeModifier(1) [stc::create "RangeModifier" \
#         -under $StreamBlock(1) \
#         -ModifierMode "INCR" \
#         -Mask {00:00:FF:FF:FF:FF} \
#         -StepValue {00:00:00:00:00:01} \
#         -RecycleCount $multicast_num \
#         -RepeatCount "0" \
#         -Data {$start_mac} \
#         -DataType "NATIVE" \
#         -EnableStream "FALSE" \
#         -Offset "2" \
#         -OffsetReference {eth1.dstMac} \
#         -Active "TRUE" \
#         -LocalActive "TRUE" \
#         -Name {MAC Modifier} ]

# set StreamBlock(2) [stc::create "StreamBlock" \
#         -under $port1 \
#         -IsControlledByGenerator "TRUE" \
#         -ControlledBy {generator} \
#         -TrafficPattern "PAIR" \
#         -EndpointMapping "ONE_TO_ONE" \
#         -EnableStreamOnlyGeneration "TRUE" \
#         -EnableBidirectionalTraffic "FALSE" \
#         -EqualRxPortDistribution "FALSE" \
#         -EnableTxPortSendingTrafficToSelf "FALSE" \
#         -EnableControlPlane "FALSE" \
#         -InsertSig "TRUE" \
#         -FrameLengthMode "FIXED" \
#         -FixedFrameLength "128" \
#         -MinFrameLength "128" \
#         -MaxFrameLength "256" \
#         -StepFrameLength "1" \
#         -FillType "CONSTANT" \
#         -ConstantFillPattern "0" \
#         -EnableFcsErrorInsertion "FALSE" \
#         -Filter {} \
#         -ShowAllHeaders "FALSE" \
#         -AllowInvalidHeaders "FALSE" \
#         -AutoSelectTunnel "FALSE" \
#         -ByPassSimpleIpSubnetChecking "FALSE" \
#         -EnableHighSpeedResultAnalysis "TRUE" \
#         -EnableBackBoneTrafficSendToSelf "TRUE" \
#         -EnableResolveDestMacAddress "TRUE" \
#         -AdvancedInterleavingGroup "0" \
#         -FrameConfig [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>01:00:5E:10:00:01</dstMac><srcMac>%s</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_15569"><tos name="anon_15570"></tos></tosDiffserv></pdu></pdus></config></frame>} [get_port_mac $port1]]\
#         -Active "TRUE" \
#         -LocalActive "TRUE" \
#         -Name {01:00:5E:10:00:01} ]

#     stc::apply
    
#     lappend stream_block_list $StreamBlock(1)
#     lappend stream_block_list $StreamBlock(2)
    
#     return $stream_block_list
# }

#针对3.25 crc帧测试
proc init_3_25_stream { port1 } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under $port1 \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "TRUE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>01:0C:CD:04:00:05</dstMac><srcMac>[get_port_mac $port1]</srcMac><etherType override="true" >88BA</etherType></pdu><pdu name="proto1" pdu="custom:Custom"><pattern>4005003000000000608167800101A2816130815E800430303030820208598304000000018501018781480000000000000000</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {64  4005} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    
    return $stream_block_list
}

#针对3.11测试
proc init_3_11_stream { port_list } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under [lindex $port_list 0] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "56" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:01:01:07</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType></pdu><pdu name="custom_2004" pdu="custom:Custom"><pattern>01070008000000005A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5AA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5AA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5AA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {goose1} ]

    set StreamBlock(2) [stc::create "StreamBlock" \
        -under [lindex $port_list 0] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "56" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0C:CD:01:01:08</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType></pdu><pdu name="custom_2004" pdu="custom:Custom"><pattern>01080008000000005A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5AA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5AA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5AA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {goose2} ]
    
    set StreamBlock(3) [stc::create "StreamBlock" \
        -under [lindex $port_list 1] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0c:cd:04:00:05</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_3609" pdu="custom:Custom"><pattern>4005003000000000608167800101A2816130815E8004303030308202085983040000000185010187814800000000</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {sv1} ]

    set StreamBlock(4) [stc::create "StreamBlock" \
        -under [lindex $port_list 1] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "128" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0C:CD:04:00:06</dstMac><srcMac>00:60:0b:64:64:14</srcMac><etherType override="true" >88ba</etherType></pdu><pdu name="custom_3609" pdu="custom:Custom"><pattern>4006003000000000608167800101A2816130815E8004303030308202085983040000000185010187814800000000</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {sv2} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)
    lappend stream_block_list $StreamBlock(3)
    lappend stream_block_list $StreamBlock(4)
    
    return $stream_block_list
}

#针对2.13测试
proc init_2_13_stream { port_list } {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under [lindex $port_list 1] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0C:CD:01:00:05</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType></pdu><pdu name="custom_2548" pdu="custom:Custom"><pattern>000500080000FFFF608167800101A2816130815E800430303030820208598304000000018501018781480000000000000000</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {goose no vid} ]

    set StreamBlock(2) [stc::create "StreamBlock" \
        -under [lindex $port_list 1] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0C:CD:01:00:05</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType><vlans name="anon_5587"><Vlan name="Vlan"><pri>000</pri><id>1</id></Vlan></vlans></pdu><pdu name="custom_2548" pdu="custom:Custom"><pattern>000500080000FFFF608167800101A2816130815E800430303030820208598304000000018501018781480000000000000000</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {goose vid 1} ]

    set StreamBlock(3) [stc::create "StreamBlock" \
        -under [lindex $port_list 1] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0C:CD:01:00:05</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType><vlans name="anon_5592"><Vlan name="Vlan"><pri>000</pri><id>10</id></Vlan></vlans></pdu><pdu name="custom_2548" pdu="custom:Custom"><pattern>000500080000FFFF608167800101A2816130815E800430303030820208598304000000018501018781480000000000000000</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {goose vid 10} ]

set StreamBlock(4) [stc::create "StreamBlock" \
        -under [lindex $port_list 1] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "TRUE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame  valid="false" ><config><pdus><pdu name="eth_0" pdu="ethernet:EthernetII"><dstMac>01:0C:CD:01:00:05</dstMac><srcMac>00:00:01:01:01:01</srcMac><etherType override="true" >88b8</etherType><vlans name="anon_5597"><Vlan name="Vlan"><pri>000</pri><id>20</id></Vlan></vlans></pdu><pdu name="custom_2548" pdu="custom:Custom"><pattern>000500080000FFFF608167800101A2816130815E800430303030820208598304000000018501018781480000000000000000</pattern></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {goose vid 20} ]

    set StreamBlock(5) [stc::create "StreamBlock" \
        -under [lindex $port_list 2] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:02:00:00:00:01</dstMac><srcMac>00:03:00:00:00:01</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_5604"><tos name="anon_5605"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {ipv4 no vid} ]

set StreamBlock(6) [stc::create "StreamBlock" \
        -under [lindex $port_list 2] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:02:00:00:00:01</dstMac><srcMac>00:03:00:00:00:01</srcMac><vlans name="anon_5610"><Vlan name="Vlan"><pri>000</pri><id>1</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_5613"><tos name="anon_5614"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {ipv4 vid 1} ]

    set StreamBlock(7) [stc::create "StreamBlock" \
        -under [lindex $port_list 2] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:02:00:00:00:01</dstMac><srcMac>00:03:00:00:00:01</srcMac><vlans name="anon_5619"><Vlan name="Vlan"><pri>000</pri><id>10</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_5622"><tos name="anon_5623"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {ipv4 vid 10} ]

    set StreamBlock(8) [stc::create "StreamBlock" \
        -under [lindex $port_list 2] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "AUTO" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:02:00:00:00:01</dstMac><srcMac>00:03:00:00:00:01</srcMac><vlans name="anon_5628"><Vlan name="Vlan"><pri>000</pri><id>20</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_5631"><tos name="anon_5632"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {ipv4 vid 20} ]

    set StreamBlock(9) [stc::create "StreamBlock" \
        -under [lindex $port_list 3] \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "64" \
        -MinFrameLength "128" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>FF:FF:FF:FF:FF:FF</dstMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_5639"><tos name="anon_5640"></tos></tosDiffserv></pdu></pdus></config></frame>} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {broadcast} ]

    stc::apply
    
    lappend stream_block_list $StreamBlock(1)
    lappend stream_block_list $StreamBlock(2)
    lappend stream_block_list $StreamBlock(3)
    lappend stream_block_list $StreamBlock(4)
    lappend stream_block_list $StreamBlock(5)
    lappend stream_block_list $StreamBlock(6)
    lappend stream_block_list $StreamBlock(7)
    lappend stream_block_list $StreamBlock(8)
    lappend stream_block_list $StreamBlock(9)
    
    return $stream_block_list
}

proc get_port_mac {port_handler} {
    set location [stc::get $port_handler -location]
    set items [split $location "/"]
    set slot [lindex $items 3]
    set port_index [lindex $items 4]
    set mac [format "00:%02x:%02x:00:00:01" $slot $port_index]
    return $mac
}

proc config_stream_length_and_load {stream_block_list frame_length {load 100}} {
    foreach stream_block $stream_block_list {
        stc::config $stream_block -FixedFrameLength $frame_length -load $load
    }
    stc::apply
    # stc::sleep 2
}

############################################################################
# Stop generators and analyzers
# port
# Input Parameter:
#       generator_list: generator handler list
#       analyzer_list: analyzer handler list
#       return: 
############################################################################
proc stop_generator_analyzer { generator_list analyzer_list } {
    stc::perform generatorStop -generatorList $generator_list
    stc::sleep 3
    stc::perform analyzerStop -analyzerList $analyzer_list
    stc::log INFO  "Stop generators and analyzers succeeded"
}

# Configure result view mode
# BASIC Use the BASIC result mode. This mode provides Advanced Sequencing.
# HISTOGRAM Use the HISTOGRAM result mode.
# JITTER Use the JITTER result mode.
# INTERARRIVALTIME Use the INTERARRIVALTIME result mode.
# FORWARDING Use the FORWARDING result mode. This mode provides Advanced Sequencing.
# LATENCY_JITTER Use the LATENCY_JITTER result mode.
proc config_result_view_mode { {mode BASIC} } {
    global PROJECT
    set hResultOptions [stc::get $PROJECT -Children-ResultOptions]
    puts "\nConfigure the result view mode"
    stc::config $hResultOptions -ResultViewMode $mode \
        -StopTrafficBeforeClearingResults "FALSE" \
        -StopAnalyzerBeforeClearingResults "FALSE" \
        -SyncClearResults "FALSE" \
        -TimedRefreshResultViewMode "PERIODIC" \
        -JitterMode "RFC3393ABSOLUTEVALUE" \
        -TimedRefreshInterval "1" \
        -Active "TRUE"
}

proc config_avg_latency_result_view {port_handler_list} {
    global PROJECT
    global RESULT_LIST
    # set avg_latency_results [stc::subscribe -Parent $PROJECT \
    #     -ConfigType analyzer \
    #     -ResultType PortAvgLatencyResults \
    #     -FilenamePrefix PortAvgLatencyResults]
    # stc::apply
    # stc::sleep 1
    # return $avg_latency_results
    foreach var $port_handler_list {
        set result_info [stc::subscribe -parent $PROJECT \
            -resultParent $var \
            -configType analyzer \
            -resultType portAvgLatencyResults]
        lappend RESULT_LIST $result_info
        stc::sleep 1
        lappend result_view_list [stc::get $result_info  -resultHandleList]
    }
    stc::apply
    stc::sleep 1
    return $result_view_list
}

proc config_jitter_result_view {stream_block_list} {
    global PROJECT
    foreach var $stream_block_list {
        set jitter_results [stc::subscribe -Parent $PROJECT \
            -resultParent $var \
            -ConfigType StreamBlock \
            -ResultType RxStreamBlockResults \
            -FilenamePrefix RxStreamBlockResults \
            -viewAttributeList "bitcount bitrate droppedframecount droppedframepercent droppedframepercentrate droppedframerate framecount framerate avgjitter maxjitter minjitter octetcount octetrate rxport sigframecount sigframerate totaljitter" \
            -interval 1]
        lappend result_view_list $jitter_results
    }
    stc::apply
    stc::sleep 1
    return $result_view_list
}

proc config_tx_stream_result_view {stream_block_list} {
    global PROJECT
    foreach var $stream_block_list {
        set results [stc::subscribe -Parent $PROJECT \
            -resultParent $var \
            -ConfigType StreamBlock \
            -ResultType TxStreamBlockResults \
            -FilenamePrefix TxStreamBlockResults]
        lappend result_view_list $results
    }
    stc::apply
    stc::sleep 1
    return $result_view_list
}

proc refresh_result_view { result_view_list {sleep_time 1} } {
    foreach var $result_view_list {
        stc::perform RefreshResultView -ResultDataSet $var   
    }
    # Allow time for the summarization of the results.
    # (after is a Tcl command with units of milliseconds)
    stc::sleep $sleep_time
}

proc unsubscribe_results {} {
    global RESULT_LIST
    foreach sub $RESULT_LIST {
        stc::unsubscribe  $sub
    }
    set RESULT_LIST {}
}

proc clear_all_results {port_object_list} {
    stc::perform ResultsClearAll -PortList $port_object_list
    stc::apply
    stc::sleep 2
}

proc start_rx_capture { port filter mac } {
    # set hCapture [stc::get $port -children-capture]
    # stc::config $hCapture -mode REGULAR_MODE -srcMode RX_MODE

    set Capture(1) [lindex [stc::get $port -children-Capture] 0]
    stc::config $Capture(1) -CurrentFiltersUsed "2" -CurrentFilterBytesUsed "8"
    set CaptureFilter(1) [lindex [stc::get $Capture(1) -children-CaptureFilter] 0]
    stc::config $CaptureFilter(1) -FilterExpression [format {{ Pattern(EthernetII:Destination MAC == %s) }} $mac]
    set CaptureAnalyzerFilter(1) [stc::create "CaptureAnalyzerFilter" \
        -under $CaptureFilter(1) \
        -IsSelected "TRUE" \
        -FilterDescription {EthernetII:Destination MAC} \
        -ValueToBeMatched $mac \
        -FrameConfig  $filter ]

    stc::apply
    stc::sleep 2
    # stc::perform CaptureStart -captureProxyId $hCapture
    stc::perform CaptureStart -captureProxyId $Capture(1)
    return $Capture(1)
}

proc stop_capture { capture_handler pcap_file } {
    stc::perform CaptureStop -captureProxyId $capture_handler
    stc::perform CaptureDataSave -captureProxyId $capture_handler \
        -FileName $pcap_file
}

proc init_3_3_learn_stream { port mac_num} {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under $port \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "64" \
        -MinFrameLength "64" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>FF:FF:FF:FF:FF:FF</dstMac><srcMac>%s</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_15413"><tos name="anon_15414"></tos></tosDiffserv></pdu></pdus></config></frame>} [get_port_mac $port]] \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {LEARN} ]

set RangeModifier(1) [stc::create "RangeModifier" \
        -under $StreamBlock(1) \
        -ModifierMode "INCR" \
        -Mask {00:00:FF:FF:FF:FF} \
        -StepValue {00:00:00:00:00:01} \
        -RecycleCount $mac_num \
        -RepeatCount "0" \
        -Data [get_port_mac $port] \
        -DataType "NATIVE" \
        -EnableStream "FALSE" \
        -Offset "2" \
        -OffsetReference {eth1.srcMac} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {MAC Modifier} ]

    stc::apply
}

proc init_3_3_test_stream { src_port dst_port mac_num} {
    set StreamBlock(1) [stc::create "StreamBlock" \
        -under $src_port \
        -IsControlledByGenerator "TRUE" \
        -ControlledBy {generator} \
        -TrafficPattern "PAIR" \
        -EndpointMapping "ONE_TO_ONE" \
        -EnableStreamOnlyGeneration "TRUE" \
        -EnableBidirectionalTraffic "FALSE" \
        -EqualRxPortDistribution "FALSE" \
        -EnableTxPortSendingTrafficToSelf "FALSE" \
        -EnableControlPlane "FALSE" \
        -InsertSig "TRUE" \
        -FrameLengthMode "FIXED" \
        -FixedFrameLength "64" \
        -MinFrameLength "64" \
        -MaxFrameLength "256" \
        -StepFrameLength "1" \
        -FillType "CONSTANT" \
        -ConstantFillPattern "0" \
        -EnableFcsErrorInsertion "FALSE" \
        -Filter {} \
        -ShowAllHeaders "FALSE" \
        -AllowInvalidHeaders "FALSE" \
        -AutoSelectTunnel "FALSE" \
        -ByPassSimpleIpSubnetChecking "FALSE" \
        -EnableHighSpeedResultAnalysis "TRUE" \
        -EnableBackBoneTrafficSendToSelf "TRUE" \
        -EnableResolveDestMacAddress "TRUE" \
        -AdvancedInterleavingGroup "0" \
        -FrameConfig [format {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>%s</dstMac><srcMac>%s</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_15413"><tos name="anon_15414"></tos></tosDiffserv></pdu></pdus></config></frame>} [get_port_mac $dst_port] [get_port_mac $src_port]] \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {LEARN} ]

set RangeModifier(1) [stc::create "RangeModifier" \
        -under $StreamBlock(1) \
        -ModifierMode "INCR" \
        -Mask {00:00:FF:FF:FF:FF} \
        -StepValue {00:00:00:00:00:01} \
        -RecycleCount $mac_num \
        -RepeatCount "0" \
        -Data [get_port_mac $dst_port] \
        -DataType "NATIVE" \
        -EnableStream "FALSE" \
        -Offset "2" \
        -OffsetReference {eth1.dstMac} \
        -Active "TRUE" \
        -LocalActive "TRUE" \
        -Name {MAC Modifier} ]

    stc::apply
    lappend stream_block_list $StreamBlock(1)
    return $stream_block_list
}

