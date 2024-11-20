onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
#add wave -noupdate -label KEY -radix binary /testbench/KEY
add wave -noupdate -label HEX2 -radix binary /testbench/HEX2
add wave -noupdate -label HEX1 -radix binary /testbench/HEX1
add wave -noupdate -label HEX0 -radix binary /testbench/HEX0
add wave -noupdate -divider part1
add wave -noupdate -label inputStateStorage -radix binary {/testbench/U1/inputStateStorage[30:26]}
#add wave -noupdate -label StateStoragePrevious -radix binary {/testbench/U1/mainStateController/inputStateStoragePrevious}
add wave -noupdate -label currentState -radix binary /testbench/U1/masterFSM/currentState
add wave -noupdate -label currentSubState -radix binary /testbench/U1/mainStateController/currentSubState
#add wave -noupdate -label ScreenX -unsigned /testbench/U1/screenX
#add wave -noupdate -label ScreenY -unsigned /testbench/U1/screenY
#add wave -noupdate -label outputColour -unsigned /testbench/U1/screenReseter/outputColour
add wave -noupdate -label pressPulseShifter -radix binary /testbench/U1/pressPulseShifter
add wave -noupdate -label recievedNewData -radix binary /testbench/U1/recievedNewData
#add wave -noupdate -label inputXor -radix binary /testbench/U1/mainStateController/inputXor

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 200
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {250 us}
