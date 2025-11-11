
set SOURCES [glob "../sap-1-3/*.v"]

puts "$SOURCES"

for {set i 0} {$i < [llength $SOURCES]} {incr i} { 
    puts "Running xvlog on [lindex $SOURCES $i]"
    exec xvlog "[lindex $SOURCES $i]"
}
