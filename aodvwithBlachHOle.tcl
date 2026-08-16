set val(chan)         Channel/WirelessChannel  ;# Channel type
set val(prop)         Propagation/TwoRayGround ;# Radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# Max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# Network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(rp)           EAODV                    ;# Routing protocol
set val(x)            800		       ;# X length
set val(y)            800		       ;# Y length
set val(finish)       500	       	       ;# Finish time
set val(nn)           75		       ;# Number of mobilenodes
set mobility [lindex $argv 0]		       ;# Dynamic mobility file

set ns_ [new Simulator]

#$ns_ use-newtrace

set trf [open out_[regexp -all -inline -- {[0-9]+} $mobility].tr w]
$ns_ trace-all $trf 
set namtrace [open out_[regexp -all -inline -- {[0-9]+} $mobility].nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
 
set god_ [create-god $val(nn)]
set chan_1 [new $val(chan)]

$ns_ node-config  -adhocRouting $val(rp) \
          -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -topoInstance $topo \
                 -energyModel "EnergyModel" \
                 -initialEnergy 100.0 \
                 -txPower 0.66 \
                 -rxPower 0.395 \
                 -idelPower 0.3 \
                 -sleepPower 0.03 \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace ON \
                 -channel $chan_1
		#mjd
		#Phy/WirelessPhy set RXThresh_   1.42681e-12
#3.65262e-10
		Phy/WirelessPhy set RXThresh_   1.42681e-12
		Phy/WirelessPhy set CSThresh_   1.42681e-12
		Phy/WirelessPhy set pt_         2.28289e-11
		#Phy/WirelessPhy set pt_         0.2818
		Phy/WirelessPhy set freq_      5.9e+9
#mjd

for {set i 0} {$i < $val(nn) } { incr i } {
	set node_($i) [$ns_ node]
	$ns_ initial_node_pos $node_($i) 35
}


source $mobility
source session

$ns_ at 1.0 "[$node_(2) set ragent_] blackhole"
$ns_ at 1.0 "[$node_(5) set ragent_] blackhole"
$ns_ at 1.0 "[$node_(6) set ragent_] blackhole"
$ns_ at 0.0 "$node_(1) color blue"
$node_(1) color "blue"
$ns_ at 0.0 "$node_(2) color orange"
$node_(2) color "blue"
$ns_ at 0.0 "$node_(6) color red"
$node_(6) color "blue"

proc finish {} {
    global ns_ namtrace filename
    $ns_ flush-trace
    close $namtrace  
   exec nam out.nam &
    exit 0
}

$ns_ at $val(finish) "finish"
puts "Start of simulation..."
$ns_ run
