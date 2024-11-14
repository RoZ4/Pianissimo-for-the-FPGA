onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
//add wave -noupdate -label KEY -radix binary /testbench/KEY
add wave -noupdate -divider part1
add wave -noupdate -label inputStateStorage -radix binary {/testbench/U1/inputStateStorage[29:26]}
add wave -noupdate -label OverallState -radix binary /testbench/U1/masterFSM/currentState
add wave -noupdate -label mainLogicSubstate -radix binary /testbench/U1/mainStateController/currentSubState
add wave -noupdate -label linesDrawn -radix binary /testbench/U1/mainStateController/linesDrawn
add wave -noupdate -label retrievedNoteData -radix binary /testbench/U1/mainStateController/retrievedNoteData
add wave -noupdate -label microSecondCounter -radix binary /testbench/U1/mainStateController/microSecondCounter
add wave -noupdate -label resetTimer -radix binary /testbench/U1/mainStateController/timecounter/microSecondEnable

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
